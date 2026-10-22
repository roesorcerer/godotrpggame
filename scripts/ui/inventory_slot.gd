class_name InventorySlot
extends PanelContainer

## One backpack slot: shows the item in Inventory slot `index` and lets the
## player drag it onto another slot. Used by both the hotbar and the backpack.
## Its look comes from theme styles: `base_style` normally (InventorySlot on
## the hotbar, BackpackSlot - invisible - over the backpack art, which already
## draws its slots), InventorySlotSelected and InventorySlotLocked.

signal clicked(index: int)
signal hovered(index: int)

var index := 0
var base_style: StringName = &"InventorySlot"
var locked := false:
	set(value):
		locked = value
		theme_type_variation = &"InventorySlotLocked" if locked else base_style

@onready var _icon: TextureRect = $Icon
@onready var _count: Label = $Count


func _ready() -> void:
	theme_type_variation = base_style
	mouse_entered.connect(func(): hovered.emit(index))
	refresh()


func refresh() -> void:
	var item := Inventory.item_at(index) if not locked else null
	_icon.texture = item.icon if item != null else null
	var count := Inventory.count_at(index)
	_count.text = str(count) if item != null and count > 1 else ""
	tooltip_text = "%s\n%s" % [item.display_name, item.description] if item != null else ""


func set_selected(on: bool) -> void:
	theme_type_variation = &"InventorySlotSelected" if on else base_style


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(index)


## --- drag and drop ----------------------------------------------------------

func _get_drag_data(_at: Vector2) -> Variant:
	if locked or Inventory.item_at(index) == null:
		return null
	var preview := TextureRect.new()
	preview.texture = _icon.texture
	preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	preview.size = _icon.size * get_global_transform().get_scale()
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	set_drag_preview(preview)
	return {"from_slot": index}


func _can_drop_data(_at: Vector2, data: Variant) -> bool:
	return not locked and data is Dictionary and data.has("from_slot")


func _drop_data(_at: Vector2, data: Variant) -> void:
	Inventory.move(int(data["from_slot"]), index)
