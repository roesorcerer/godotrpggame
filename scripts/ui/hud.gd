extends CanvasLayer

## Heads-up display: the day, the clock, Gas, the state of the house, money,
## the interaction prompt, the day-end summary, and the fade between days.

const FADE_IN_TIME := 0.9
const FADE_OUT_TIME := 0.45

@onready var _fade: ColorRect = $Fade
@onready var _day_label: Label = $Panel/Margin/Rows/DayLabel
@onready var _time_label: Label = $Panel/Margin/Rows/TimeLabel
@onready var _gas_bar: ProgressBar = $Panel/Margin/Rows/GasBar
@onready var _house_label: Label = $Panel/Margin/Rows/HouseLabel
@onready var _money_label: Label = $Panel/Margin/Rows/MoneyLabel
@onready var _prompt: Label = $Prompt
@onready var _summary: PanelContainer = $Summary
@onready var _summary_title: Label = $Summary/Margin/Rows/Title
@onready var _summary_body: Label = $Summary/Margin/Rows/Body

var _fade_tween: Tween
var _holding_pause := false
var _summary_open := false


func _ready() -> void:
	EventBus.day_started.connect(_on_day_started)
	EventBus.day_ended.connect(_on_day_ended)
	EventBus.minute_ticked.connect(_on_minute_ticked)
	EventBus.gas_changed.connect(_on_gas_changed)
	EventBus.money_changed.connect(_on_money_changed)
	EventBus.interaction_prompt.connect(_on_interaction_prompt)
	EventBus.room_state_changed.connect(func(_r): _refresh_house())

	_fade.color.a = 1.0
	_summary.visible = false
	_prompt.text = ""
	_prompt.visible = false
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
	_day_label.text = "Day %d  ·  %s" % [day, GameClock.weekday_name()]
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

	var chores := 0
	var study_sessions := 0
	var finished: Array[String] = []
	for entry in GameState.day_log:
		match entry.get("kind", ""):
			"chore":
				chores += 1
			"coursework":
				study_sessions += 1
				if entry.get("finished", false):
					finished.append(String(entry.get("name", "")))

	if chores == 0 and study_sessions == 0:
		lines.append("You didn't get anything done.")
	else:
		if chores > 0:
			lines.append("%d %s done." % [chores, "job" if chores == 1 else "jobs"])
		if study_sessions > 0:
			lines.append("%d hour%s at the table." % [study_sessions, "" if study_sessions == 1 else "s"])
	for title in finished:
		lines.append("Finished: %s" % title)

	var backlog := CourseworkSystem.backlog()
	if backlog > 0:
		lines.append("%d assignment%s still in the packet." % [backlog, "" if backlog == 1 else "s"])

	if not MessSystem.can_host():
		lines.append("You couldn't have anyone over like this.")

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


func _refresh_house() -> void:
	var worst := MessSystem.worst_grime()
	var clutter := MessSystem.total_clutter()
	var text := ""
	if worst >= 4:
		text = "House bad"
	elif worst >= 3:
		text = "House messy"
	elif not MessSystem.can_host():
		text = "Can't have anyone over"
	else:
		text = "House OK"
	if clutter > 0:
		text += "  ·  %d clutter" % clutter
	_house_label.text = text
	_house_label.modulate = Color(0.85, 0.55, 0.4) if worst >= 3 else Color.WHITE


func _on_gas_changed(current: int, max_value: int) -> void:
	_gas_bar.max_value = maxi(max_value, 1)
	_gas_bar.value = current
	_gas_bar.tooltip_text = "Gas %d / %d" % [current, max_value]


func _on_money_changed(amount: int) -> void:
	_money_label.text = "$%d" % amount


func _on_interaction_prompt(text: String) -> void:
	if text == "":
		_prompt.text = ""
		_prompt.visible = false
	else:
		_prompt.text = "[E]  %s" % text
		_prompt.visible = true
