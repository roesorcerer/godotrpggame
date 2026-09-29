class_name ChoreData
extends Resource

## One thing that needs doing. Authored as a .tres in data/chores/ - you should
## never have to open a script to add a chore.

enum Kind {
	GRIME,     ## dishes, ash, laundry. Daily, cheap, endless.
	CLUTTER,   ## Bruce's stuff. Weekly, expensive, yields sellable junk.
	REPAIR,    ## one-time, needs money and a part, stays fixed.
	CARE,      ## looking after someone. Moves strain, not the house.
}

@export var id: StringName = &""
@export var display_name := ""
@export_multiline var flavor := ""

## Which room this belongs to. Must match a MessSystem room id.
@export var room: StringName = &""
@export var kind: Kind = Kind.GRIME

@export_range(1, 30) var gas_cost := 6
@export_range(5, 240, 5) var minutes := 30

## How much it reduces the room's grime or clutter.
@export_range(0, 5) var relief := 1

## Cash straight from the job - returnable bottles, scrap weight, a neighbour
## paying you. A real inventory lands later; this stands in for it.
@export var money_reward := 0

## Story gating and tool requirements.
@export var requires_flag: StringName = &""
@export var required_tool: StringName = &""

## CARE chores only: how much this moves Doris's strain (negative helps).
@export var strain_delta := 0
