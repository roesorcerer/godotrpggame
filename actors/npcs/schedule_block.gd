class_name ScheduleBlock
extends Resource

## One stretch of an NPC's day: from start_hour until the next block starts,
## they're at `spot` in `place`. Blocks are checked against GameClock, so an
## NPC is wherever their schedule says the moment a scene loads - they only
## visibly walk when the clock crosses a start_hour while you're watching.

## 24h clock. The block lasts until the next block's start_hour; before the
## first block of the day the last one is still running (overnight).
@export_range(0, 23) var start_hour := 7

## Which days this block applies to. A good day is one Mom can care (she isn't
## hungover or passed out: Mom.can_care()). Give a good-day and a bad-day
## block the same start_hour to branch the day; "Any day" blocks apply to both.
@export_enum("Any day", "Good days", "Bad days") var days := 0

## Scene file name without .tscn: &"ranch", &"ranch_interior",
## &"ranch_second_floor_interior", &"barn"... A place with no scene yet
## (the barn) still works: the NPC just walks off toward it and is gone.
@export var place: StringName = &""

## Name of a node in that scene (found anywhere in the tree):
##  - a Seat, or a node with a Seat child (the couch): they sit on it.
##  - a node with Marker2D children: they wander between them, pausing at each.
##  - anything else (a Marker2D): they walk there and stay.
@export var spot: StringName = &""

## Animation once settled. On a seat it's the base name ("sit_legsout" picks
## the left/right version from the seat's facing, like the player's seats).
## Two special poses lie down at the spot (a bed or couch marker; a "Covers"
## child of the marker is shown while they're there):
##   "sleep" - asleep (the "sleep" animation, or the head with "z z")
##   "lie"   - lying awake (head and shoulders above the covers)
## Empty = idle in whatever way they were last facing.
@export var pose: StringName = &""

## Can the player talk to them during this block (false while asleep).
@export var can_talk := true

## What the NPC says during this block instead of their usual small talk.
## Empty = the NpcTalk's own small_talk.
@export_multiline var small_talk: Array[String] = []
