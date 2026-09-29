extends Node

## The beating heart. Day length, the minute tick, and the day boundary.
## Everything in Part One of the design is a function of this node.

const MINUTES_PER_DAY := 1080          ## 6:00 AM -> midnight (18 hours)
const START_HOUR := 6
const REAL_SECONDS_PER_GAME_MINUTE := 0.7   ## ~12.6 real minutes per day
const BEDTIME_HOUR := 23               ## in bed before this = full rest
const SUMMER_LENGTH := 84              ## the Pine Grove deadline

const DAY_NAMES := ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

var day := 1
var minutes := 0                       ## minutes elapsed since 6:00 AM

var _accum := 0.0
var _pause_requests := 0               ## stacking pauses: menus, dialogue, cutscenes

## --- pausing ---------------------------------------------------------------
## Counter-based so overlapping systems (a menu opened during dialogue)
## can't unpause each other by accident.

func is_paused() -> bool:
	return _pause_requests > 0

func pause_depth() -> int:
	return _pause_requests

func request_pause() -> void:
	_pause_requests += 1

func release_pause() -> void:
	_pause_requests = maxi(0, _pause_requests - 1)


func _ready() -> void:
	# Let the other autoloads finish _ready before anyone hears day_started.
	await get_tree().process_frame
	EventBus.day_started.emit(day)


func _process(delta: float) -> void:
	if is_paused():
		return
	_accum += delta
	while _accum >= REAL_SECONDS_PER_GAME_MINUTE:
		_accum -= REAL_SECONDS_PER_GAME_MINUTE
		minutes += 1
		EventBus.minute_ticked.emit(minutes)
		if minutes % 60 == 0:
			EventBus.hour_ticked.emit(clock_hour())
		if minutes >= MINUTES_PER_DAY:
			# Stayed up past midnight: you don't choose to sleep, you stop.
			end_day(true)
			return


## --- reading the clock -----------------------------------------------------

func clock_hour() -> int:
	return START_HOUR + minutes / 60

func clock_minute() -> int:
	return minutes % 60

func time_string() -> String:
	var h := clock_hour()
	var h12 := h % 12
	if h12 == 0:
		h12 = 12
	return "%d:%02d %s" % [h12, clock_minute(), "AM" if h < 12 else "PM"]

func weekday() -> int:
	return (day - 1) % 7

func weekday_name() -> String:
	return DAY_NAMES[weekday()]

func is_weekend() -> bool:
	return weekday() >= 5

func days_remaining() -> int:
	return maxi(0, SUMMER_LENGTH - day)

## True during the 7-9 AM window - best concentration for coursework (see §05).
func is_quiet_hours() -> bool:
	return clock_hour() >= 7 and clock_hour() < 9

## Advance the clock directly. Chores and coursework call this.
func advance(mins: int) -> void:
	if mins <= 0:
		return
	var before := minutes
	minutes = mini(minutes + mins, MINUTES_PER_DAY)
	for h in range(START_HOUR + before / 60 + 1, clock_hour() + 1):
		EventBus.hour_ticked.emit(h)
	EventBus.minute_ticked.emit(minutes)
	if minutes >= MINUTES_PER_DAY:
		end_day(true)


## --- the day boundary ------------------------------------------------------

## passed_out: true when the clock ran out rather than the player choosing bed.
func end_day(passed_out := false) -> void:
	var summary := {
		"day": day,
		"weekday": weekday_name(),
		"slept_at": minutes,
		"passed_out": passed_out,
		"money": GameState.money,
	}
	EventBus.day_ended.emit(day, summary)

	day += 1
	minutes = 0
	_accum = 0.0
	GameState.begin_new_day(summary["slept_at"], passed_out)

	EventBus.day_started.emit(day)
