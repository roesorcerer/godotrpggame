class_name ChoreData
extends Resource

## One thing Mom wants done. Authored as a .tres in data/chores/ - you should
## never have to open a script to add a chore.
##
## Chores pay nothing. Doing one lifts Mom's mood; still undone at bedtime, it
## costs the same amount. Like watering in Stardew: easy, daily, and the game
## never makes you - she just gets meaner if you don't.

@export var id: StringName = &""
@export var display_name := ""
@export_multiline var flavor := ""

## Where it happens: the room_id of the RoomZone its spot sits in.
@export var room: StringName = &""

## Days it's on the list, 0 = Mon ... 6 = Sun. Empty means every day.
@export var weekdays: Array[int] = []

@export_range(0, 30) var gas_cost := 6
@export_range(5, 240, 5) var minutes := 30

## How much Mom cares: gained when done, lost when missed.
@export_range(1, 10) var mood := 3

## Story gating: off the list entirely until this flag is set.
@export var requires_flag: StringName = &""
