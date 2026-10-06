class_name MessProp
extends Node2D

## The visible side of a chore: dirty dishes by the sink, a full ashtray, mud
## in the hall. It shows while its chore is on today's list and not done, and
## vanishes the moment you do it.
##
## The art is whatever you put under it - a Sprite2D, or a TileMapLayer painted
## with the interior tileset. A StaticBody2D child blocks movement while the
## mess is showing.

## The chore that clears this. Required.
@export var chore: StringName = &""


func _ready() -> void:
	if chore == &"" or ChoreSystem.get_chore(chore) == null:
		push_warning("%s: set `chore` to a chore id from data/chores/ (got '%s')." % [get_path(), chore])
	EventBus.chores_changed.connect(_refresh)
	_refresh()


func is_showing() -> bool:
	var data := ChoreSystem.get_chore(chore)
	return data != null and ChoreSystem.is_needed(data)


func _refresh() -> void:
	var showing := is_showing()
	visible = showing
	for child in get_children():
		if child is CollisionObject2D:
			for shape in child.get_children():
				if shape is CollisionShape2D or shape is CollisionPolygon2D:
					shape.set_deferred("disabled", not showing)
