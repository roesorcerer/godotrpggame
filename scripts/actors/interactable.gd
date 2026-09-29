class_name Interactable
extends Area2D

## Base for everything the player can press E on: doors, beds, NPCs, junk
## piles, the sink, the TV, the answering machine. Build it once, use it
## everywhere. Subclasses override can_interact() / get_prompt() / _on_interact().
##
## Interactables live on physics layer 3 and scan nothing themselves; the
## player's InteractionSensor is what does the looking.

const LAYER := 4          ## bit 3

@export var prompt := "Look"

## Higher wins when two things overlap at the same distance.
## (Not `priority` - Area2D already defines that.)
@export var interact_priority := 0

## Optional: hidden entirely until this flag is set (story gating).
@export var requires_flag: StringName = &""

signal interacted(by: Node2D)


func _ready() -> void:
	collision_layer = LAYER
	collision_mask = 0
	monitoring = false        ## it is found, it does not search
	monitorable = true


func can_interact(_by: Node2D) -> bool:
	if requires_flag != &"" and not GameState.has_flag(requires_flag):
		return false
	return true


func get_prompt(_by: Node2D) -> String:
	return prompt


## Entry point. The sensor calls this; subclasses override _on_interact().
func interact(by: Node2D) -> void:
	if not can_interact(by):
		return
	_on_interact(by)
	interacted.emit(by)


func _on_interact(_by: Node2D) -> void:
	pass
