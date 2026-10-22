extends Node

## Dev-only smoke test for the kitchen-chair meals: the chair offers breakfast
## in the morning and dinner in the evening, eating restores Gas and passes the
## time, and a meal can't be eaten twice in one day.
##   godot --headless --path . res://scenes/dev/seat_smoke.tscn

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
	var player: Node2D = load("res://scenes/player.tscn").instantiate()
	add_child(player)
	var chair: Node2D = load("res://scenes/props/chair.tscn").instantiate()
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

	_finished = true