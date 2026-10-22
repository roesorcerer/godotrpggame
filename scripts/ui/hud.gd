extends CanvasLayer

## Heads-up display: the day, the clock, Gas, Mom and today's chores, money,
## the interaction prompt, the day-end summary, and the fade between days.

const FADE_IN_TIME := 0.9
const FADE_OUT_TIME := 0.45
const GAS_NOTCHES := 4          ## notches drawn in progress_notches_full_vertical.png
const GAS_FILL_SECONDS := 0.5
const SPEECH_SECONDS := 5.0

@onready var _fade: ColorRect = $Fade
@onready var _day_label: Label = $ClockPanel/DayLabel
@onready var _time_label: Label = $ClockPanel/TimeLabel
@onready var _gas_bar: TextureProgressBar = $GasBox/Row/GasBar
## One Label per slot in the money bar, left to right.
@onready var _money_digits: Array[Node] = $ClockPanel/MoneyDigits.get_children()
@onready var _star_button: Button = $ClockPanel/StarButton
@onready var _chore_list: TextureRect = $ChoreList
@onready var _chore_title: Label = $ChoreList/Title
## One Label per box in assets/UI/quest_list.png, top to bottom.
@onready var _chore_rows: Array[Node] = $ChoreList/Rows.get_children()
@onready var _speech: TextureRect = $Speech
@onready var _speech_label: Label = $Speech/Text
@onready var _speech_name: Label = $Speech/Name
@onready var _speech_portrait: TextureRect = $Speech/Portrait
@onready var _prompt: Label = $Prompt
@onready var _summary: PanelContainer = $Summary
@onready var _summary_title: Label = $Summary/Margin/Rows/Title
@onready var _summary_body: Label = $Summary/Margin/Rows/Body

var _fade_tween: Tween
var _gas_tween: Tween
var _speech_id := 0                  ## so an old timer can't hide a newer line
var _holding_pause := false
var _summary_open := false
var _backpack_open := false
var _current_room: StringName = &""       ## last RoomZone the player entered


func _ready() -> void:
	EventBus.day_started.connect(_on_day_started)
	EventBus.day_ended.connect(_on_day_ended)
	EventBus.minute_ticked.connect(_on_minute_ticked)
	EventBus.gas_changed.connect(_on_gas_changed)
	_star_button.toggled.connect(func(on: bool): _chore_list.visible = on)
	$Backpack.toggled.connect(func(open: bool):
		_backpack_open = open
		_refresh_hotbar())
	EventBus.money_changed.connect(_on_money_changed)
	EventBus.interaction_prompt.connect(_on_interaction_prompt)
	EventBus.chores_changed.connect(_refresh_house)
	EventBus.quests_changed.connect(_refresh_house)
	EventBus.npc_said.connect(_on_npc_said)
	EventBus.mom_mood_changed.connect(func(_m): _refresh_house())
	EventBus.room_entered.connect(_on_room_entered)

	_fade.color.a = 1.0
	_summary.visible = false
	_prompt.text = ""
	_prompt.visible = false
	_speech.visible = false
	_on_gas_changed(GameState.gas, GameState.gas_max)
	_on_money_changed(GameState.money)
	_refresh_clock()
	_refresh_house()


func _unhandled_input(event: InputEvent) -> void:
	if _summary_open:
		if event.is_action_pressed("interact") or event.is_action_pressed("sleep"):
			get_viewport().set_input_as_handled()
			_close_summary()
		return

	# Dev shortcut: skip to the next morning without walking to the bed.
	if event.is_action_pressed("sleep") and not GameClock.is_paused():
		GameClock.end_day(false)


## --- fading ----------------------------------------------------------------
## The tween drives the visual; the await runs off a timer so a killed tween
## can never strand a caller (or leak the clock pause it is holding).

func fade_to_black(duration := FADE_OUT_TIME) -> void:
	_start_fade(1.0, duration)
	await get_tree().create_timer(duration).timeout


func fade_from_black(duration := FADE_IN_TIME) -> void:
	_start_fade(0.0, duration)
	await get_tree().create_timer(duration).timeout


func _start_fade(target_alpha: float, duration: float) -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(_fade, "color:a", target_alpha, duration)


## --- day boundary ----------------------------------------------------------

func _on_day_ended(day: int, summary: Dictionary) -> void:
	_fade.color.a = 1.0
	_on_interaction_prompt("")
	_show_summary(day, summary)


func _on_day_started(day: int) -> void:
	_day_label.text = "%s. %d" % [GameClock.weekday_name(), day]
	_refresh_clock()
	_refresh_house()

	# Hold the clock until the player can see the world again. Guarded so a
	# second day starting mid-fade can't leak a pause request.
	if not _holding_pause:
		_holding_pause = true
		GameClock.request_pause()

	# Wait out the summary before the morning fade, so the player isn't reading
	# last night's report over today's kitchen.
	while _summary_open:
		await get_tree().process_frame

	await fade_from_black()
	if _holding_pause:
		_holding_pause = false
		GameClock.release_pause()


## --- the day-end summary ---------------------------------------------------

func _show_summary(day: int, summary: Dictionary) -> void:
	_summary_title.text = "Day %d  ·  %s" % [day, summary.get("weekday", "")]
	_summary_body.text = _compose_summary(summary)
	_summary.visible = true
	_summary_open = true


func _close_summary() -> void:
	_summary_open = false
	_summary.visible = false


func _compose_summary(summary: Dictionary) -> String:
	var lines: Array[String] = []

	if summary.get("passed_out", false):
		lines.append("You were still up at midnight.")

	var done := int(summary.get("chores_done", 0))
	var missed: Array = summary.get("chores_missed", [])
	if done == 0 and missed.is_empty():
		lines.append("Nothing on the list today.")
	elif done == 0:
		lines.append("You didn't do any of your chores.")
	else:
		lines.append("%d %s done." % [done, "chore" if done == 1 else "chores"])
	if not missed.is_empty():
		lines.append("Skipped: %s" % ", ".join(missed))

	var change := int(summary.get("mood_change", 0))
	var mood_line := "Mom: %s" % Mom.tier_label()
	if change > 0:
		mood_line += "  (warmer)"
	elif change < 0:
		mood_line += "  (cooler)"
	lines.append(mood_line)

	var quests: Array = summary.get("quests_done", [])
	if not quests.is_empty():
		lines.append("Finished: %s" % ", ".join(quests))

	lines.append("$%d" % GameState.money)
	return "\n".join(lines)


## --- readouts --------------------------------------------------------------

func _on_minute_ticked(_day_minutes: int) -> void:
	_refresh_clock()


func _refresh_clock() -> void:
	_time_label.text = GameClock.time_string()
	if GameClock.is_quiet_hours():
		_time_label.modulate = Color(0.55, 0.82, 0.85)   # the quiet hours read as calm
	else:
		_time_label.modulate = Color.WHITE


const ROW_COLOR := Color(0.2, 0.18, 0.26)
const ROW_DONE_COLOR := Color(0.52, 0.5, 0.6)       ## ticked off
const ROW_HERE_COLOR := Color(0.15, 0.4, 0.3)       ## can be done in this room


## The header shows Mom's mood (brick red when she's upset); each box below
## holds one chore, then one quest. Overflow folds into the last box.
func _refresh_house() -> void:
	var left := ChoreSystem.remaining().size()
	var total := ChoreSystem.todays_list().size()
	_chore_title.text = "Today  ·  Mom: %s" % Mom.tier_label()
	_chore_title.tooltip_text = "Chores %d/%d" % [total - left, total]
	_chore_title.add_theme_color_override("font_color",
			Color(1.0, 0.55, 0.5) if Mom.mood() < 45 else Color(0.937, 0.945, 0.922))

	var here: Array = ChoreSystem.available_in_room(_current_room) if _current_room != &"" else []
	var entries: Array[Array] = []        ## [text, color]
	for chore in ChoreSystem.todays_list():
		var done := ChoreSystem.is_done(chore)
		var color := ROW_DONE_COLOR if done else (ROW_HERE_COLOR if chore in here else ROW_COLOR)
		entries.append(["%s %s" % ["[x]" if done else "[ ]", chore.display_name], color])
	for line in _quest_lines():
		entries.append([line, ROW_COLOR])
	if entries.is_empty():
		entries.append(["Nothing on the list today.", ROW_DONE_COLOR])

	if entries.size() > _chore_rows.size():
		var hidden := entries.slice(_chore_rows.size() - 1)
		entries.resize(_chore_rows.size() - 1)
		entries.append(["+%d more" % hidden.size(), ROW_COLOR,
				"\n".join(hidden.map(func(e): return e[0]))])

	for i in _chore_rows.size():
		var row: Label = _chore_rows[i]
		var entry: Array = entries[i] if i < entries.size() else ["", ROW_COLOR]
		row.text = entry[0]
		row.tooltip_text = entry[2] if entry.size() > 2 else entry[0]
		row.add_theme_color_override("font_color", entry[1])


## Active quests with what to do next, then who has something new to hand out.
func _quest_lines() -> Array[String]:
	var lines: Array[String] = []
	for quest in QuestSystem.active():
		lines.append("> %s: %s" % [quest.display_name, quest.goal_text()])
	for giver in QuestSystem.givers_with_offers():
		lines.append("! Talk to %s" % Data.NPC_NAMES.get(giver, String(giver)))
	return lines


## Dialogue in the big box on the left; who's talking in the portrait box and
## name strip on the right (assets/UI/npc_dialogue.png).
func _on_npc_said(speaker: String, text: String, portrait: Texture2D) -> void:
	_speech_label.text = text
	_speech_name.text = speaker
	_speech_portrait.texture = portrait
	_speech.visible = true
	_refresh_hotbar()
	_speech_id += 1
	var id := _speech_id
	await get_tree().create_timer(SPEECH_SECONDS).timeout
	if id == _speech_id:
		_speech.visible = false
		_refresh_hotbar()


## Like Stardew, the hotbar steps aside while the full backpack is open, and
## while someone is talking so it doesn't crowd the speech box.
func _refresh_hotbar() -> void:
	$Hotbar.visible = not _backpack_open and not _speech.visible


func _on_room_entered(room_id: StringName) -> void:
	_current_room = room_id
	_refresh_house()


func _on_gas_changed(current: int, max_value: int) -> void:
	_gas_bar.max_value = maxi(max_value, 1)
	# Fill whole notches only (any gas left shows at least one), and slide the
	# green in/out rather than jumping.
	var notch := _gas_bar.max_value / GAS_NOTCHES
	var target := ceilf(current / notch) * notch
	if _gas_tween:
		_gas_tween.kill()
	_gas_tween = create_tween()
	_gas_tween.tween_property(_gas_bar, "value", target, GAS_FILL_SECONDS)
	_gas_bar.tooltip_text = "Gas %d / %d" % [current, max_value]


func _on_money_changed(amount: int) -> void:
	# Right-aligned, one digit per slot; unused slots on the left stay blank.
	var text := str(clampi(amount, 0, int(pow(10, _money_digits.size())) - 1))
	text = text.lpad(_money_digits.size())
	for i in _money_digits.size():
		_money_digits[i].text = text[i].strip_edges()


func _on_interaction_prompt(text: String) -> void:
	if text == "":
		_prompt.text = ""
		_prompt.visible = false
	else:
		_prompt.text = "[E]  %s" % text
		_prompt.visible = true
