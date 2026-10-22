extends Node

## Dev-only smoke test for M2: the daily chore list and Mom's mood.
##   godot --headless --path . res://dev/m2_smoke.tscn
## The interior is being rebuilt, so missing spots print a SKIP note instead
## of failing; anything that IS placed must be wired correctly.

var _failures: Array[String] = []
var _finished := false            ## set by the last line of _run(); a script error skips it
var _chores_completed: Array = []


func _ready() -> void:
	EventBus.chore_completed.connect(func(id): _chores_completed.append(id))
	await get_tree().process_frame
	await get_tree().process_frame
	await _run()
	if not _finished:
		_failures.append("_run() did not finish - see the script error above")
	if _failures.is_empty():
		print("M2 SMOKE: PASS")
		get_tree().quit(0)
	else:
		for f in _failures:
			printerr("M2 SMOKE FAIL: ", f)
		get_tree().quit(1)


func _check(cond: bool, label: String) -> void:
	if not cond:
		_failures.append(label)


func _run() -> void:
	# --- content loaded from data/, not code ---
	_check(ChoreSystem.count() > 0, "chores loaded from data/chores/")
	for chore in ChoreSystem.all():
		_check(chore.id != &"", "a chore has no id")
		_check(chore.room != &"", "%s has no room" % chore.id)
		for d in chore.weekdays:
			_check(d >= 0 and d <= 6, "%s has weekday %d (0-6 only)" % [chore.id, d])
	var dishes := ChoreSystem.get_chore(&"dishes")
	_check(dishes != null, "dishes chore exists")
	if dishes == null:
		return
	_check(dishes.weekdays.is_empty(), "dishes is an every-day chore")

	# --- the weekly schedule ---
	var laundry := ChoreSystem.get_chore(&"laundry")      # Mon + Thu
	if laundry != null:
		GameClock.day = 1                                  # Mon
		_check(ChoreSystem.is_scheduled_today(laundry), "laundry is on Monday's list")
		GameClock.day = 2                                  # Tue
		_check(not ChoreSystem.is_scheduled_today(laundry), "laundry is not on Tuesday's list")
		GameClock.day = 1

	# --- story gating keeps a chore off the list ---
	var gated := ChoreData.new()
	gated.requires_flag = &"__smoke_gate"
	_check(not ChoreSystem.is_scheduled_today(gated), "a gated chore is off the list")
	GameState.set_flag(&"__smoke_gate")
	_check(ChoreSystem.is_scheduled_today(gated), "setting the flag puts it on")
	GameState.flags.erase(&"__smoke_gate")

	# --- doing a chore: Gas, clock, mood, log, signal ---
	GameState.gas = 100
	GameState.doris["mood"] = 50
	GameClock.minutes = 60 * 4                             # 10:00 AM
	var mins_before := GameClock.minutes
	_check(ChoreSystem.is_needed(dishes), "dishes is needed this morning")
	_check(ChoreSystem.perform(dishes), "dishes performed")
	_check(GameState.gas == 100 - dishes.gas_cost, "gas spent, got %d" % GameState.gas)
	_check(GameClock.minutes == mins_before + dishes.minutes, "clock advanced by the chore")
	_check(Mom.mood() == 50 + dishes.mood, "Mom's mood rose by %d, got %d" % [dishes.mood, Mom.mood()])
	_check(_chores_completed.has(&"dishes"), "chore_completed fired")
	_check(GameState.day_log.any(func(e): return e.get("id") == &"dishes"), "the day log recorded it")

	# --- once a day ---
	_check(not ChoreSystem.is_needed(dishes), "done dishes drop off the list")
	_check(not ChoreSystem.perform(dishes), "and can't be done twice")

	# --- too tired to work ---
	var other: ChoreData = ChoreSystem.remaining().front() if not ChoreSystem.remaining().is_empty() else null
	if other != null and other.gas_cost > 0:
		GameState.gas = other.gas_cost - 1
		_check(ChoreSystem.blocked_reason(other) == "Too tired", "low gas blocks a chore")
		_check(not ChoreSystem.perform(other), "a blocked chore does nothing")
		_check(not ChoreSystem.is_done(other), "and isn't marked done")

	# --- bedtime: every missed chore costs its mood ---
	GameState.doris["mood"] = 80
	var missed_cost := 0
	for chore in ChoreSystem.remaining():
		missed_cost += chore.mood
	var summary := {}
	ChoreSystem.close_day(summary)
	_check(Mom.mood() == clampi(80 - missed_cost, 0, Mom.MAX_MOOD),
		"missed chores cost %d mood, got %d" % [missed_cost, Mom.mood()])
	_check(summary.has("chores_missed") and summary.has("mood_change"), "summary carries the outcome")

	# --- Mom's tiers and breakfast ---
	GameState.doris["mood"] = Mom.MAX_MOOD
	_check(Mom.tier() == &"warm", "full mood is Warm")
	_check(Mom.makes_breakfast(), "a Warm Mom makes breakfast")
	GameState.doris["mood"] = 0
	_check(Mom.tier() == &"mean", "zero mood is Mean")
	_check(not Mom.makes_breakfast(), "a Mean Mom doesn't")
	Mom.change(-50)
	_check(Mom.mood() == 0, "mood can't go below 0")

	# --- a new day clears the list ---
	GameClock.end_day(false)
	_check(GameState.chores_done.is_empty(), "the chore list resets each morning")

	await _check_interior()
	_finished = true


## Whatever chore spots ARE placed must point at real chores in their room.
func _check_interior() -> void:
	var interior: Node = load("res://world/ranch_interior/ranch_interior.tscn").instantiate()
	add_child(interior)
	await get_tree().physics_frame

	var spots := interior.find_children("*", "ChoreSpot", true, false)
	if spots.is_empty():
		print("M2 SMOKE SKIP: no ChoreSpots in the interior yet")
	for spot in spots:
		var room_id: StringName = spot.get("_room_id")
		var pinned: StringName = spot.get("only_chore")
		if pinned == &"":
			continue
		var chore := ChoreSystem.get_chore(pinned)
		_check(chore != null, "%s pins a real chore '%s'" % [spot.name, pinned])
		if chore != null and room_id != &"":
			_check(chore.room == room_id, "%s sits in %s but pins %s (%s)" % [spot.name, room_id, pinned, chore.room])

	# Chores with nowhere to do them: a note, not a failure, while the
	# interior is being laid out.
	var spot_rooms := spots.map(func(sp): return sp.get("_room_id"))
	var homeless := ChoreSystem.all().filter(func(c): return not spot_rooms.has(c.room))
	if not homeless.is_empty():
		print("M2 SMOKE SKIP: no spot yet for %s" % [homeless.map(func(c): return String(c.id))])

	interior.queue_free()
	await get_tree().process_frame
