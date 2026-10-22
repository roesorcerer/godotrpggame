class_name ItemPickup
extends Area2D

## Something lying on the ground. Walk over it and it goes in the backpack;
## if the backpack is full, whatever didn't fit stays on the ground.

@export var item: ItemData
@export_range(1, 999) var count := 1

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	collision_layer = 0
	collision_mask = Data.PHYSICS_PLAYER
	monitorable = false
	body_entered.connect(_on_body_entered)
	if item != null:
		_sprite.texture = item.icon
	# A small bob so it reads as something to pick up.
	var tween := create_tween().set_loops()
	tween.tween_property(_sprite, "position:y", _sprite.position.y - 2, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_sprite, "position:y", _sprite.position.y, 0.6).set_trans(Tween.TRANS_SINE)


func _on_body_entered(body: Node2D) -> void:
	if item == null or not body.is_in_group(SceneRouter.PLAYER_GROUP):
		return
	count = Inventory.add(item.id, count)
	if count == 0:
		queue_free()
