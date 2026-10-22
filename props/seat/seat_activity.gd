class_name SeatActivity
extends Resource

## One thing the player can do on a Seat. A seat offers the first activity in
## its list that is available right now, so put the most specific ones first
## (e.g. "Eat breakfast" 6-9 AM) and a plain "Sit" last.

@export var prompt := "Sit"

## SpriteFrames animation on the player, without the facing suffix:
## "sit" plays "sit_right" or "sit_left" depending on the seat's facing.
@export var animation: StringName = &"sit"

## Available from this hour up to (not including) to_hour, 24h clock.
@export_range(0, 24) var from_hour := 0
@export_range(0, 24) var to_hour := 24

## Optional story gate: only offered while this GameState flag is set.
@export var requires_flag: StringName = &""

@export_group("Effect")
## Marks this activity done for the day (see GameState.meals_today) so it can't
## be repeated until tomorrow. Empty = the activity is always repeatable.
@export var id: StringName = &""
## Gas restored when this activity is done (a meal, a rest).
@export_range(0, 100) var restore_gas := 0
## In-game minutes that pass when this activity is done.
@export_range(0, 240, 5) var minutes := 0
## Narration shown when it's done. Empty = no line.
@export_multiline var line := ""


func is_available() -> bool:
	var hour := GameClock.clock_hour()
	if hour < from_hour or hour >= to_hour:
		return false
	if requires_flag != &"" and not GameState.has_flag(requires_flag):
		return false
	if id != &"" and GameState.meals_today.has(String(id)):
		return false
	return true
