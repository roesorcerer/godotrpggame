extends Node

## Dev-only smoke test for M2: room decay, chores, and the coursework
## concentration curve.
##   godot --headless --path . res://scenes/dev/m2_smoke.tscn

var _failures: Array[String] = []
var _chores_completed: Array = []


func _ready() -> void:
	EventBus.chore_completed.connect(func(id): _chores_completed.append(id))
	await get_tree().process_frame
	await get_tree().process_frame
	_run()
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
	_check(ChoreSystem.count() == 6, "6 chores loaded, got %d" % ChoreSystem.count())
	_check(CourseworkSystem.count() == 3, "3 assignments loaded, got %d" % CourseworkSystem.count())
	var dishes := ChoreSystem.get_chore(&"dishes")
	_check(dishes != null, "dishes chore exists")
	if dishes == null:
		return
	_check(dishes.room == &"kitchen", "dishes belongs to the kitchen")
	_check(dishes.kind == ChoreData.Kind.GRIME, "dishes is a grime chore")

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
