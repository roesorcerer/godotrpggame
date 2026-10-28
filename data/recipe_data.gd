class_name RecipeData
extends Resource

## One thing the player can cook at the stove. Authored as a .tres in
## data/recipes/ - add a recipe without touching code. The stove's menu lists
## every known recipe and greys out the ones you're missing ingredients for.

enum Method {STOVETOP, OVEN}

@export var id: StringName = &""
@export var display_name := ""

## Shown in the cooking menu: how you make it, in the teen's own words.
@export_multiline var instructions := ""

## Item id -> how many. Every ingredient is used up when cooking starts.
@export var ingredients: Dictionary[StringName, int] = {}

## STOVETOP cooks in the pan on the burners; OVEN goes in behind the door.
@export var method := Method.STOVETOP

## Game minutes from starting until it's ready to eat.
@export_range(1, 120) var cook_minutes := 15

## The item it makes (data/items/). How much Gas it gives and what the
## player says when eating it live on that item.
@export var result: StringName = &""

## Story gating: not in the menu until this flag is set (a recipe you learn).
@export var requires_flag: StringName = &""


func is_known() -> bool:
	return requires_flag == &"" or GameState.has_flag(requires_flag)
