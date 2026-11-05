extends Node

## Dev-only smoke test for the M0 foundation. Not part of the game.
## Run headless:
##   godot --headless --path . res://dev/m0_smoke.tscn
## Exits with code 0 if the clock, the day boundary and the Gas rules behave.

var _failures: Array[String] = []
var _finished := false            ## set by the last line of _run(); a script error skips it
var _seen_day_started := 0
var _seen_day_ended := 0
var _seen_hours := 0
var _advanced: Array[int] = []    ## time_advanced payloads


func _ready() -> void:
	EventBus.day_started.connect(func(_d): _seen_day_started += 1)
	EventBus.day_ended.connect(func(_d, _s): _seen_day_ended += 1)
	EventBus.hour_ticked.connect(func(_h): _seen_hours += 1)
	EventBus.time_advanced.connect(func(m): _advanced.append(m))

	await get_tree().process_frame
	await get_tree().process_frame

	await _run()
	if not _finished:
		_failures.append("_run() did not finish - see the script error above")

	if _failures.is_empty():
		print("M0 SMOKE: PASS")
		get_tree().quit(0)
	else:
		for f in _failures:
			printerr("M0 SMOKE FAIL: ", f)
		get_tree().quit(1)


## Missed chores cost Mom's mood at bedtime, and her mood decides breakfast,
## which lifts the Gas cap. These cap tests are about bedtime and dinner, so
## tick off every chore and pin her mood first to isolate them.
func _settle_house(mom_mood: int) -> void:
	GameState.chores_done = ChoreSystem.all().map(func(c): return String(c.id))
	GameState.doris["mood"] = mom_mood


func _check(condition: bool, label: String) -> void:
	if not condition:
		_failures.append(label)


func _run() -> void:
	# --- clock reads correctly at the start of a day ---
	_check(GameClock.day == 1, "day starts at 1")
	_check(GameClock.clock_hour() == 7, "starts at 7 AM, got %d" % GameClock.clock_hour())
	_check(GameClock.time_string() == "7:00 AM", "time_string, got %s" % GameClock.time_string())
	_check(GameClock.weekday_name() == "Mon", "day 1 is Monday")
	_check(_seen_day_started == 1, "day_started fired once at boot, got %d" % _seen_day_started)

	# --- the clock never ticks on its own ---
	for i in 30:
		await get_tree().process_frame
	_check(GameClock.minutes == 0, "standing still keeps the clock at 7 AM, got %s" % GameClock.time_string())

	# --- advancing time ---
	GameClock.advance(60 * 9)                      # 7 AM -> 4 PM
	_check(GameClock.time_string() == "4:00 PM", "after +9h, got %s" % GameClock.time_string())
	_check(_seen_hours == 9, "9 hour ticks, got %d" % _seen_hours)

	GameClock.advance(40)
	_check(GameClock.time_string() == "4:40 PM", "after +40m, got %s" % GameClock.time_string())
	_check(_advanced == [540, 40], "time_advanced sends the minutes spent, got %s" % [_advanced])

	# --- the quiet hours window (7-9 AM) ---
	_check(not GameClock.is_quiet_hours(), "4:40 PM is not quiet hours")

	# --- Gas spending ---
	GameState.gas = 50
	_check(GameState.spend_gas(20), "can spend affordable Gas")
	_check(GameState.gas == 30, "Gas is 30 after spending 20, got %d" % GameState.gas)
	_check(not GameState.spend_gas(999), "cannot overspend Gas")
	_check(GameState.gas == 30, "failed spend leaves Gas alone")

	# --- sleeping on time: full rest (isolated from the breakfast bonus) ---
	_settle_house(Mom.BREAKFAST_MOOD - 1)
	var day_before := GameClock.day
	GameClock.end_day(false)                        # slept at 3:40 PM, before 11 PM
	_check(GameClock.day == day_before + 1, "day advanced")
	_check(GameClock.minutes == 0, "clock reset to 6 AM")
	_check(_seen_day_ended == 1, "day_ended fired once")
	_check(GameClock.weekday_name() == "Tue", "day 2 is Tuesday")
	_check(GameState.gas_max == GameState.GAS_BASE_MAX,
		"full rest keeps the 100 cap, got %d" % GameState.gas_max)

	# --- Mom in a good mood makes breakfast, which lifts the ceiling ---
	_settle_house(Mom.BREAKFAST_MOOD)
	GameClock.end_day(false)
	_check(GameState.gas_max == GameState.GAS_BASE_MAX + GameState.GAS_BONUS_BREAKFAST,
		"breakfast lifts the cap to 110, got %d" % GameState.gas_max)
	_check(GameState.gas == GameState.gas_max, "you wake up full")

	# --- skipping dinner ---
	_settle_house(Mom.BREAKFAST_MOOD - 1)
	GameState.skipped_dinner = true
	GameClock.end_day(false)
	_check(GameState.gas_max == GameState.GAS_BASE_MAX - GameState.GAS_PENALTY_NO_DINNER,
		"no dinner costs 20 off the cap, got %d" % GameState.gas_max)
	_check(not GameState.skipped_dinner, "dinner flag resets each morning")

	# --- staying up past midnight: reduced cap ---
	_settle_house(Mom.BREAKFAST_MOOD - 1)
	GameClock.advance(GameClock.MINUTES_PER_DAY)    # runs the clock out -> passed out
	_check(GameState.gas_max == GameState.GAS_CAP_PASSED_OUT,
		"passing out caps Gas at 70, got %d" % GameState.gas_max)

	# --- pause stacking (the HUD holds one while its fade runs) ---
	while GameClock.is_paused():
		GameClock.release_pause()
	GameClock.request_pause()
	GameClock.request_pause()
	GameClock.release_pause()
	_check(GameClock.is_paused(), "two pauses, one release = still paused")
	GameClock.release_pause()
	_check(not GameClock.is_paused(), "balanced releases unpause")
	GameClock.release_pause()
	_check(not GameClock.is_paused(), "extra release cannot go negative")

	# --- save round-trip (M3 leans on this) ---
	GameState.money = 137
	GameState.set_flag(&"met_hal")
	var blob := GameState.to_dict()
	GameState.money = 0
	GameState.from_dict(blob)
	_check(GameState.money == 137, "money survives a save round-trip")
	_check(GameState.has_flag(&"met_hal"), "flags survive a save round-trip")
	_finished = true
