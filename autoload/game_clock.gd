extends Node

## The beating heart. Day length, the minute tick, and the day boundary.
## Everything in Part One of the design is a function of this node.
## Time never passes on its own: advance() is the only thing that moves it.

const MINUTES_PER_DAY := 17 * 60       ## 7:00 AM -> midnight (17 hours)
const START_HOUR := 7
const BEDTIME_HOUR := 23               ## in bed before this = full rest
const SUMMER_LENGTH := 28              ## the end-of-summer deadline

const DAY_NAMES := ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

## Fixed beats of the day (GDD 5.1): hour (24h) -> anchor id. advance()
## emits EventBus.anchor_reached once when it crosses each one.
const ANCHORS := {
	18: &"dinner",
	21: &"night",
}

var day := 1
var minutes := 0                       ## minutes elapsed since START_HOUR

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


## --- reading the clock -----------------------------------------------------

func clock_hour() -> int:
	return START_HOUR + int(floor(minutes / 60.0))


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

## True during the 7-9 AM window - the quiet start of the day.
func is_quiet_hours() -> bool:
	return clock_hour() >= 7 and clock_hour() < 9

## The only way time moves: every action spends minutes (chores, meals,
## seat activities, cooking). Past midnight ends the day as passed out.
func advance(mins: int) -> void:
	if mins <= 0:
		return
	var before := minutes
	minutes = mini(minutes + mins, MINUTES_PER_DAY)
	for h in range(START_HOUR + int(floor(before / 60.0 + 1)), clock_hour() + 1):
		EventBus.hour_ticked.emit(h)
		if ANCHORS.has(h):
			EventBus.anchor_reached.emit(ANCHORS[h])
	EventBus.minute_ticked.emit(minutes)
	EventBus.time_advanced.emit(minutes - before)
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
	# Settle today's chore list (and Mom's mood) before anyone reads the summary.
	ChoreSystem.close_day(summary)
	QuestSystem.close_day(summary)
	EventBus.day_ended.emit(day, summary)

	day += 1
	minutes = 0
	GameState.begin_new_day(summary["slept_at"], passed_out)

	EventBus.day_started.emit(day)
