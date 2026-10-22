extends TextureRect

## The always-visible row along the bottom of the screen: the first
## Data.HOTBAR_SIZE backpack slots. Mouse wheel or a click picks the held slot.
## assets/UI/quickbar-items.png already draws the slot boxes; this places
## invisible slots on top of them. Coordinates are pixels in the cropped art
## (see the AtlasTexture region in hud.tscn).

const SLOT_SCENE := preload("res://scenes/ui/inventory_slot.tscn")

## Left edge of each box in the art; the gaps aren't even, so they're listed.
const SLOT_X := [0, 35, 73, 111, 149, 187, 225, 263, 299]
const SLOT_SIZE := Vector2(30, 23)

var _slots: Array[InventorySlot] = []


func _ready() -> void:
	for i in Data.HOTBAR_SIZE:
		var slot: InventorySlot = SLOT_SCENE.instantiate()
		slot.index = i
		slot.base_style = &"BackpackSlot"
		slot.position = Vector2(SLOT_X[i], 0)
		slot.custom_minimum_size = SLOT_SIZE
		slot.size = SLOT_SIZE
		slot.clicked.connect(Inventory.select)
		add_child(slot)
		_slots.append(slot)
	EventBus.inventory_changed.connect(_refresh)
	EventBus.hotbar_selected.connect(func(_i): _refresh())
	_refresh()


func _refresh() -> void:
	for slot in _slots:
		slot.refresh()
		slot.set_selected(slot.index == Inventory.selected)


func _unhandled_input(event: InputEvent) -> void:
	if not visible or GameClock.is_paused():
		return
	if event.is_action_pressed("hotbar_next"):
		Inventory.select(Inventory.selected + 1)
	elif event.is_action_pressed("hotbar_prev"):
		Inventory.select(Inventory.selected - 1)
