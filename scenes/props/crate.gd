class_name Crate
extends Interactable

## A wooden crate the player opens with E for a small reward. It uses the
## standard Interactable contract, so the player's InteractionSensor finds it
## and the HUD shows the prompt - no custom proximity or key handling needed.

## What's inside. Point it at an ItemData to make opening worthwhile; leave it
## empty for a purely decorative crate that just plays its lid animation.
@export var loot: ItemData
@export_range(1, 99) var loot_count := 3

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var opened := false


func _ready() -> void:
	super()
	if prompt == "Look":
		prompt = "Open crate"


## Once it's open there's nothing left to do with it, so it stops offering.
func can_interact(_by: Node2D) -> bool:
	return super(_by) and not opened


func _on_interact(_by: Node2D) -> void:
	if opened:
		return
	opened = true
	animation_player.play("outdoor_objects/crate_open")
	if loot != null:
		Inventory.add(loot.id, loot_count)
