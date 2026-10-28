class_name ItemData
extends Resource

## One kind of thing that can sit in the backpack. Authored as a .tres in
## data/items/ - add, edit or remove items without touching code.

@export var id: StringName = &""
@export var display_name := ""
@export_multiline var description := ""
@export var icon: Texture2D
@export var category: Enum.ItemCategory = Enum.ItemCategory.MISC

## TOOL items only: which tool the player swings while holding this.
@export var tool: Enum.Tool = Enum.Tool.AXE

## How many fit in one slot. 1 = doesn't stack (tools).
@export_range(1, 999) var max_stack := 99

## What a shop would pay for one. 0 = can't be sold.
@export var sell_price := 0

@export_group("Food")
## Gas restored by eating one. 0 = not something you eat (raw eggs, a box
## of dry noodles). Eaten from a Seat: the kitchen table, the couch.
@export_range(0, 100) var gas := 0
## What the player says when they eat one. Empty = no line.
@export_multiline var eat_line := ""


func is_edible() -> bool:
	return gas > 0
