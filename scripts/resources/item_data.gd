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
