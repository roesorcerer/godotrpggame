extends Control

## The backpack's trash can: drop an item here to throw it away.


func _can_drop_data(_at: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("from_slot")


func _drop_data(_at: Vector2, data: Variant) -> void:
	Inventory.discard(int(data["from_slot"]))
