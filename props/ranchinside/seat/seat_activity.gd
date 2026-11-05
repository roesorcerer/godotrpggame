class_name SeatActivity
extends Resource

## One thing the player can do on a Seat: Mom's breakfast at the table,
## watching TV or reading on the couch. Every available one is an option in
## the seat's menu; the first available one also names the seat's prompt and
## the pose you sit down in, so put the most specific first and a plain
## "Sit" last.

@export var prompt := "Sit"

## SpriteFrames animation on the player. "sit" plays "sit_right" or
## "sit_left" by the seat's facing; an animation with no facing versions
## ("reading") plays as it is.
@export var animation: StringName = &"sit"

## Available from this hour up to (not including) to_hour, 24h clock.
@export_range(0, 24) var from_hour := 0
@export_range(0, 24) var to_hour := 24

## Optional story gate: only offered while this GameState flag is set.
@export var requires_flag: StringName = &""

## Mom's family dinner: gone once you've missed her 6 PM call
## (GameState.skipped_family_dinner) - you cook for yourself instead.
@export var family_dinner := false

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


## What it costs and gives, for the menu hint: "45 min, once a day".
func summary() -> String:
	var parts: Array[String] = []
	if minutes > 0:
		parts.append("%d min" % minutes)
	if restore_gas > 0:
		parts.append("+%d Gas" % restore_gas)
	if id != &"":
		parts.append("once a day")
	return ", ".join(parts)


func is_available() -> bool:
	var hour := GameClock.clock_hour()
	if hour < from_hour or hour >= to_hour:
		return false
	if requires_flag != &"" and not GameState.has_flag(requires_flag):
		return false
	if family_dinner and GameState.skipped_family_dinner:
		return false
	if id != &"" and GameState.meals_today.has(String(id)):
		return false
	return true
