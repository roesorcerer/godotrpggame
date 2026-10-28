extends Node

## Dev-only smoke test for the kitchen chairs: sitting opens a menu; it offers
## breakfast in the morning and dinner in the evening, eating restores Gas and
## passes the time, a meal can't be eaten twice in one day, food from the
## backpack is eaten sitting down, and mirrored chairs face the right way.
##   godot --headless --path . res://dev/seat_smoke.tscn

var _failures: Array[String] = []
var _finished := false            ## set by the last line of _run(); a script error skips it


func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await _run()
	if not _finished:
		_failures.append("_run() did not finish - see the script error above")
	if _failures.is_empty():
		print("SEAT SMOKE: PASS")
		get_tree().quit(0)
	else:
		for f in _failures:
			printerr("SEAT SMOKE FAIL: ", f)
		get_tree().quit(1)


func _check(cond: bool, label: String) -> void:
	if not cond:
		_failures.append(label)


func _run() -> void:
	var guard := 0
	while GameClock.is_paused() and guard < 600:
		await get_tree().process_frame
		guard += 1

	var prompts: Array[String] = []
	EventBus.interaction_prompt.connect(func(t): prompts.append(t))

	# Chair and player share a spot, so the player's sensor must find the seat.
	var player: Node2D = load("res://actors/player/player.tscn").instantiate()
	add_child(player)
	var chair: Node2D = load("res://props/ranchinside/chair/chair.tscn").instantiate()
	add_child(chair)
	var seat: Seat = chair.get_node("Seat")
	for i in 4:
		await get_tree().physics_frame

	_check(seat.activities.size() == 3, "the chair carries 3 activities, got %d" % seat.activities.size())
	_check(prompts.has("Eat breakfast"), "the sensor offered breakfast, got %s" % [prompts])

	# --- morning: breakfast ---
	GameClock.minutes = 60                 # 7:00 AM
	GameState.meals_today = []
	var morning := seat.current_activity()
	_check(morning != null and morning.prompt == "Eat breakfast",
			"7 AM offers breakfast, got '%s'" % (morning.prompt if morning != null else "<none>"))

	GameState.gas = 40
	var mins_before := GameClock.minutes
	seat.interact(player)
	_check(seat.occupant == player, "E sits you down")
	var menu := _menu()
	_check(menu != null, "sitting opens the menu")
	_check(menu != null and menu.option_texts().has("Eat breakfast"), "the menu offers breakfast")
	_check(menu != null and not menu.option_texts().has("Sit"), "plain Sit isn't listed (Esc is 'just sit')")
	if menu != null:
		menu.choose("Eat breakfast")
	await get_tree().process_frame
	_check(GameState.gas == 60, "breakfast restored 20 Gas, got %d" % GameState.gas)
	_check(GameClock.minutes == mins_before + 30, "breakfast passed 30 min, got +%d" % (GameClock.minutes - mins_before))
	_check(GameState.meals_today.has("breakfast"), "breakfast was marked eaten today")

	# Same morning again: the meal is spent, so the chair falls back to plain Sit.
	player.stand_up()
	var again := seat.current_activity()
	_check(again != null and again.prompt == "Sit",
			"breakfast can't repeat; expected 'Sit', got '%s'" % (again.prompt if again != null else "<none>"))

	# --- evening: dinner ---
	GameClock.minutes = 60 * 12            # 6:00 PM
	var evening := seat.current_activity()
	_check(evening != null and evening.prompt == "Eat dinner",
			"6 PM offers dinner, got '%s'" % (evening.prompt if evening != null else "<none>"))

	# --- food from the backpack, eaten sitting down ---
	Inventory.add(&"mac_and_cheese", 1)
	GameState.gas = 10
	seat.interact(player)
	menu = _menu()
	_check(menu != null and menu.option_texts().has("Eat mac and cheese"), "the table offers your mac and cheese")
	mins_before = GameClock.minutes
	if menu != null:
		menu.choose("Eat mac and cheese")
	await get_tree().process_frame
	_check(GameState.gas == 10 + Inventory.get_item(&"mac_and_cheese").gas, "eating it restored its Gas")
	_check(Inventory.count_of(&"mac_and_cheese") == 0, "and used it up")
	_check(GameClock.minutes == mins_before + Seat.EAT_MINUTES, "eating takes time")
	GameState.gas = GameState.gas_max
	Inventory.add(&"mac_and_cheese", 1)
	seat.interact(player)
	menu = _menu()
	if menu != null:
		_check(not menu.choose("Eat mac and cheese"), "can't eat when you're full")
		menu.choose("Stand up")
	await get_tree().process_frame
	_check(seat.occupant == null, "Stand up stands you up")
	Inventory.remove(&"mac_and_cheese")

	# --- a new day resets the meals ---
	GameState.begin_new_day(0, false)
	_check(GameState.meals_today.is_empty(), "a new day clears meals_today")

	# --- a mirrored chair seats you facing the other way ---
	_check(seat.seated_facing() == "right", "an unflipped chair faces right")
	# The way the interior flips chair2: half a turn plus a vertical flip.
	chair.rotation = PI
	chair.scale = Vector2(1, -1)
	_check(seat.is_mirrored(), "rotation PI + scale.y -1 counts as mirrored")
	_check(seat.seated_facing() == "left", "a mirrored chair faces left")
	_check(is_equal_approx(seat.sit_position().x - chair.global_position.x, -seat.sit_offset.x),
			"the sit offset mirrors with the chair")
	chair.rotation = 0.0
	chair.scale = Vector2(-1, 1)
	_check(seat.seated_facing() == "left", "scale.x -1 also faces left")

	chair.queue_free()
	await _check_couch(player)
	_finished = true


## The couch: TV, a book, food - but not schoolwork, and not while Mom's on it.
func _check_couch(player: Node2D) -> void:
	if player.seat != null:
		player.stand_up()
	while _menu() != null:          # anything left open by the chair checks
		_menu().close()
	var couch: Node2D = load("res://props/ranchinside/couch/couch.tscn").instantiate()
	add_child(couch)
	await get_tree().physics_frame
	var seat: Seat = couch.get_node("Seat")
	_check(seat.allows_eating and not seat.allows_study, "the couch is for eating, not studying")

	GameClock.minutes = (Mom.SLEEP_HOUR - GameClock.START_HOUR) * 60 + 30    # 10:30 PM
	_check(seat.is_taken_by_mom(), "Mom's asleep on the couch at night")
	_check(seat.get_prompt(player) == "Mom's asleep here", "the prompt says so")
	seat.interact(player)
	_check(seat.occupant == null and _menu() == null, "you can't sit on her")

	GameClock.minutes = (16 - GameClock.START_HOUR) * 60                    # 4 PM
	GameState.meals_today = []
	_check(not seat.is_taken_by_mom(), "in the afternoon it's free")
	Inventory.add(&"pizza", 1)
	seat.interact(player)
	_check(seat.occupant == player, "sit on the couch")
	var sprite := player.get_node("AnimatedSprite2D") as AnimatedSprite2D
	_check(sprite.animation == &"sit_forward", "the couch seats you facing forward, got %s" % sprite.animation)
	_check(player.global_position.y > couch.global_position.y, "you sort in front of the couch, not behind it")
	var menu := _menu()
	var texts := menu.option_texts() if menu != null else []
	_check(texts.has("Watch TV") and texts.has("Read a book"), "TV and a book on offer (%s)" % [texts])
	_check(texts.has("Eat pizza"), "you can eat on the couch")
	_check(not texts.has("Study math"), "but not study")

	var xp := School.skill_xp(&"expression")
	if menu != null:
		menu.choose("Read a book")
	await get_tree().process_frame
	_check(School.skill_xp(&"expression") == xp + 10, "reading practises Expression")
	_check(sprite.animation == &"sit_forward", "and you stay seated facing forward, got %s" % sprite.animation)

	seat.interact(player)
	menu = _menu()
	texts = menu.option_texts() if menu != null else []
	_check(not texts.has("Read a book"), "one book a day")
	GameState.gas = 50
	var mins := GameClock.minutes
	if menu != null:
		menu.choose("Watch TV")
	await get_tree().process_frame
	_check(GameState.gas == 58 and GameClock.minutes == mins + 60, "an hour of TV: +8 Gas")
	player.stand_up()
	Inventory.remove(&"pizza", Inventory.count_of(&"pizza"))
	GameState.gas = GameState.gas_max
	couch.queue_free()


func _menu() -> ChoiceMenu:
	for node in get_tree().root.get_children():
		if node is ChoiceMenu and not node.is_queued_for_deletion():
			return node
	return null