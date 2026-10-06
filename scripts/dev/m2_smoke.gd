extends Node

## Dev-only smoke test for M2: room decay, chores, and the coursework
## concentration curve.
##   godot --headless --path . res://scenes/dev/m2_smoke.tscn

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


func _about(a: float, b: float, eps := 0.001) -> bool:
	return absf(a - b) <= eps


func _run() -> void:
	# --- content loaded from data/, not code ---
	_check(ChoreSystem.count() == 21, "21 chores loaded, got %d" % ChoreSystem.count())
	_check(CourseworkSystem.count() == 3, "3 assignments loaded, got %d" % CourseworkSystem.count())
	var dishes := ChoreSystem.get_chore(&"dishes")
	_check(dishes != null, "dishes chore exists")
	if dishes == null:
		return
	_check(dishes.room == &"kitchen", "dishes belongs to the kitchen")
	_check(dishes.kind == ChoreData.Kind.GRIME, "dishes is a grime chore")

	# --- every chore points at a real room ---
	for chore in ChoreSystem.all():
		_check(MessSystem.ROOMS.has(chore.room), "%s is in unknown room '%s'" % [chore.id, chore.room])

	# --- nothing can pile up that the player has no way to clear ---
	for id in MessSystem.room_ids():
		var spec: Dictionary = MessSystem.ROOMS[id]
		var start: Dictionary = MessSystem.STARTING_STATE.get(id, {})
		var gets_grime := int(spec["daily_grime"]) > 0 or int(start.get("grime", 0)) > 0
		var gets_clutter := int(spec["weekly_clutter"]) > 0 or int(start.get("clutter", 0)) > 0
		var has_grime := false
		var has_clutter := false
		for chore in ChoreSystem.all():
			if chore.room != id:
				continue
			has_grime = has_grime or chore.kind == ChoreData.Kind.GRIME
			has_clutter = has_clutter or chore.kind == ChoreData.Kind.CLUTTER
		_check(not gets_grime or has_grime, "%s gets grimy but no chore cleans it" % id)
		_check(not gets_clutter or has_clutter, "%s gets cluttered but no chore clears it" % id)

	# --- a shut room sits outside the loop until the story opens it ---
	_check(not MessSystem.is_open(&"music_room"), "the music room starts shut")
	_check(ChoreSystem.available_in_room(&"music_room").is_empty(), "a shut room offers no chores")
	_check(not MessSystem.open_room_ids().has(&"music_room"), "a shut room isn't counted")

	# --- you moved into a mess: there is work waiting on day 1 ---
	_check(MessSystem.total_clutter() > 0, "the house starts cluttered")
	_check(not MessSystem.can_host(), "you can't have anyone over on day 1")
	_check(not ChoreSystem.available_in_room(&"living_room").is_empty(),
		"the living room has something to do on day 1")

	# --- decay: scrub first so the deltas are the only thing measured ---
	for id in MessSystem.room_ids():
		var r := MessSystem.get_room(id)
		r["grime"] = 0
		r["clutter"] = 0
	GameState.doris["today"] = &"slow"        # keep the Under-day bonus out of it
	GameClock.end_day(false)
	_check(GameClock.day == 2, "rolled to day 2")
	_check(MessSystem.grime(&"kitchen") == 1, "kitchen picked up 1 grime, got %d" % MessSystem.grime(&"kitchen"))
	_check(MessSystem.grime(&"living_room") == 2,
		"living room picks up 2 (Bruce smokes), got %d" % MessSystem.grime(&"living_room"))
	_check(MessSystem.grime(&"porch") == 0, "the porch doesn't get grimy")
	_check(MessSystem.grime(&"music_room") == 0, "a shut room doesn't decay")

	# --- the hosting gate, which is the lever that matters ---
	_check(MessSystem.can_host(), "grime 2 still lets you have people over")
	MessSystem.add_grime(&"living_room", 1)
	_check(not MessSystem.can_host(), "grime 3 does not")
	MessSystem.add_grime(&"living_room", -1)

	# --- doing a chore ---
	GameState.gas = 100
	GameClock.minutes = 60 * 4                 # 10:00 AM
	MessSystem.get_room(&"kitchen")["grime"] = 3
	var gas_before := GameState.gas
	var mins_before := GameClock.minutes
	_check(ChoreSystem.is_needed(dishes), "dishes is needed at grime 3")
	_check(ChoreSystem.perform(dishes), "dishes performed")
	_check(GameState.gas == gas_before - dishes.gas_cost,
		"gas spent, got %d expected %d" % [GameState.gas, gas_before - dishes.gas_cost])
	_check(MessSystem.grime(&"kitchen") == 3 - dishes.relief,
		"grime reduced, got %d" % MessSystem.grime(&"kitchen"))
	_check(GameClock.minutes == mins_before + dishes.minutes, "clock advanced by the chore")
	_check(_chores_completed.has(&"dishes"), "chore_completed fired")

	# --- a clean room offers nothing ---
	MessSystem.get_room(&"kitchen")["grime"] = 0
	_check(not ChoreSystem.is_needed(dishes), "a clean kitchen needs no dishes")
	_check(ChoreSystem.available_in_room(&"kitchen").is_empty(), "nothing to do in a clean kitchen")

	# --- clutter pays, because the hoard is the economy ---
	var haul := ChoreSystem.get_chore(&"haul_boxes")
	_check(haul != null and haul.kind == ChoreData.Kind.CLUTTER, "haul_boxes is a clutter chore")
	MessSystem.get_room(&"living_room")["clutter"] = 2
	GameState.gas = 100
	GameState.money = 0
	_check(ChoreSystem.perform(haul), "hauled boxes")
	_check(MessSystem.clutter(&"living_room") == 1, "clutter reduced, got %d" % MessSystem.clutter(&"living_room"))
	_check(GameState.money == haul.money_reward, "clutter paid out $%d, got $%d" % [haul.money_reward, GameState.money])

	# --- too tired to work ---
	GameState.gas = 2
	MessSystem.get_room(&"kitchen")["grime"] = 2
	_check(ChoreSystem.blocked_reason(dishes) == "Too tired", "low gas blocks a chore")
	_check(not ChoreSystem.perform(dishes), "a blocked chore does nothing")
	_check(MessSystem.grime(&"kitchen") == 2, "blocked chore left the room alone")

	# --- concentration: the quiet hours, the sag, and running on empty ---
	GameState.gas = 90
	GameClock.minutes = 90                     # 7:30 AM, rested
	_check(_about(CourseworkSystem.concentration(), CourseworkSystem.QUIET_HOURS_BONUS),
		"quiet hours give %.2f, got %.2f" % [CourseworkSystem.QUIET_HOURS_BONUS, CourseworkSystem.concentration()])

	GameClock.minutes = 60 * 4                 # 10:00 AM, ordinary
	_check(_about(CourseworkSystem.concentration(), 1.0),
		"a normal hour gives 1.0, got %.2f" % CourseworkSystem.concentration())

	GameClock.minutes = 60 * 7                 # 1:00 PM, the sag
	_check(_about(CourseworkSystem.concentration(), CourseworkSystem.SAG_PENALTY),
		"the sag gives %.2f, got %.2f" % [CourseworkSystem.SAG_PENALTY, CourseworkSystem.concentration()])

	GameState.gas = 10                         # running on fumes, still in the sag
	_check(_about(CourseworkSystem.concentration(), CourseworkSystem.SAG_PENALTY * CourseworkSystem.LOW_GAS_PENALTY),
		"low gas halves it again, got %.2f" % CourseworkSystem.concentration())

	GameClock.minutes = 90                     # quiet hours but exhausted: no bonus
	_check(CourseworkSystem.concentration() < 1.0,
		"the quiet hours are worth nothing on an empty tank, got %.2f" % CourseworkSystem.concentration())

	# --- working through the packet ---
	var first := CourseworkSystem.next_assignment(&"civics")
	_check(first != null and first.id == &"civics_01", "civics starts at unit 1")
	if first == null:
		return
	var backlog_before := CourseworkSystem.backlog()
	_check(backlog_before == 3, "3 assignments outstanding, got %d" % backlog_before)

	for i in 3:
		GameState.gas = 90
		GameClock.minutes = 60 * 4              # 10:00 AM, concentration 1.0
		var earned := CourseworkSystem.study(CourseworkSystem.next_assignment(&"civics"))
		_check(_about(earned, 1.0), "session %d earned 1.0, got %.2f" % [i + 1, earned])

	_check(CourseworkSystem.is_done(first), "unit 1 finished after 3 sessions")
	_check(CourseworkSystem.next_assignment(&"civics").id == &"civics_02", "moved on to unit 2")
	_check(CourseworkSystem.backlog() == 2, "backlog fell to 2, got %d" % CourseworkSystem.backlog())

	# --- a filthy table can't be worked at ---
	GameState.gas = 90
	MessSystem.get_room(&"kitchen")["grime"] = 5
	var desk := Desk.new()
	desk.subject = &"civics"
	desk.room = &"kitchen"
	_check(desk.get_prompt(null) == "Can't work at this table", "grime 5 closes the table")
	desk.free()

	# --- the day log feeds the summary ---
	_check(GameState.day_log.size() >= 4, "day log recorded the work, got %d" % GameState.day_log.size())
	var kinds := GameState.day_log.map(func(e): return e.get("kind", ""))
	_check(kinds.has("chore") and kinds.has("coursework"), "log has both chores and coursework")

	# --- coursework survives a save ---
	var blob := GameState.to_dict()
	GameState.coursework = {}
	GameState.from_dict(blob)
	_check(CourseworkSystem.is_done(first), "finished units survive a save round-trip")

	await _check_interior()
	_finished = true


## The real first floor: every spot and prop knows its room from the zone it
## sits in, and the mess on screen follows the room's state.
func _check_interior() -> void:
	var entered: Array = []
	EventBus.room_entered.connect(func(r): entered.append(r))
	var interior: Node = load("res://scenes/world/ranch_interior.tscn").instantiate()
	add_child(interior)
	await get_tree().physics_frame
	await get_tree().physics_frame

	var spots := interior.find_children("*", "ChoreSpot", true, false)
	_check(spots.size() >= 10, "interior has chore spots, got %d" % spots.size())
	for spot in spots:
		var room_id: StringName = spot.get("_room_id")
		_check(MessSystem.ROOMS.has(room_id), "%s resolved to a real room, got '%s'" % [spot.name, room_id])
		var pinned: StringName = spot.get("only_chore")
		if pinned != &"":
			var chore := ChoreSystem.get_chore(pinned)
			_check(chore != null, "%s pins a real chore '%s'" % [spot.name, pinned])
			if chore != null:
				_check(chore.room == room_id, "%s sits in %s but pins %s (%s)" % [spot.name, room_id, pinned, chore.room])

	# every open first-floor room has somewhere to clean it
	var spot_rooms := spots.map(func(sp): return sp.get("_room_id"))
	for id in MessSystem.room_ids():
		if MessSystem.ROOMS[id]["floor"] == &"first" and MessSystem.is_open(id):
			_check(spot_rooms.has(id), "no chore spot in the %s" % id)

	var desk := interior.find_children("*", "Desk", true, false)
	_check(desk.size() == 1 and desk[0].call("_room") == &"kitchen", "the desk is in the kitchen")

	# mess shows at its threshold and clears when the room is cleaned
	var props := interior.find_children("*", "MessProp", true, false)
	_check(not props.is_empty(), "interior has mess props")
	for prop in props:
		_check(MessSystem.ROOMS.has(prop.get("_room_id")), "%s resolved to a real room" % prop.name)
	var boxes5 := interior.find_child("Boxes5", true, false)
	if boxes5 != null:
		MessSystem.get_room(&"living_room")["clutter"] = 0
		MessSystem.add_clutter(&"living_room", 5)
		_check(boxes5.visible, "the wall of boxes shows at clutter 5")
		MessSystem.add_clutter(&"living_room", -1)
		_check(not boxes5.visible, "and goes when one load is hauled")

	# walking into a zone announces the room
	var player := interior.find_child("CharacterBody2D", true, false) as Node2D
	if player != null:
		entered.clear()
		player.global_position = Vector2(200, 120)      # kitchen
		await get_tree().physics_frame
		await get_tree().physics_frame
		_check(entered.has(&"kitchen"), "entering the kitchen zone announced it, got %s" % [entered])

	interior.queue_free()
	await get_tree().process_frame

	# a spot parented under a room belongs to that room, wherever it's dragged
	var zone := RoomZone.new()
	zone.room_id = &"bathroom"
	var nested := ChoreSpot.new()
	nested.position = Vector2(-5000, -5000)       # outside every rectangle
	zone.add_child(nested)
	add_child(zone)
	_check(nested.get("_room_id") == &"bathroom", "a spot under a RoomZone takes its room from the parent")
	_check(zone.y_sort_enabled, "a RoomZone y-sorts its contents")
	zone.queue_free()
	await get_tree().process_frame
