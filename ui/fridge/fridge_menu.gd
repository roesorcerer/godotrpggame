class_name FridgeMenu
extends CanvasLayer

## What's in the kitchen fridge (left) and the food in your backpack (right).
## Click an item to move one across; Shift+click moves the whole stack.
## Time stops while it's open. The fridge opens it with open() and closes its
## door when `closed` fires; the menu frees itself.

signal closed()

## Shown when there's nothing in the fridge.
const EMPTY_TEXT := "Ketchup, a box of baking soda, and nothing else."

@onready var _fridge_list: VBoxContainer = %FridgeList
@onready var _backpack_list: VBoxContainer = %BackpackList
@onready var _empty_label: Label = %EmptyLabel
@onready var _info: Label = %Info

var _is_open := false
var _refresh_queued := false


func _ready() -> void:
	_empty_label.text = EMPTY_TEXT
	# One click changes both the fridge and the backpack; redraw once.
	EventBus.fridge_changed.connect(_queue_refresh)
	EventBus.inventory_changed.connect(_queue_refresh)


func open() -> void:
	_is_open = true
	GameClock.request_pause()
	_refresh()
	_focus_first()


func close() -> void:
	if not _is_open:
		return
	_is_open = false
	GameClock.release_pause()
	closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("inventory") \
			or event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		close()


func _queue_refresh() -> void:
	if not _refresh_queued:
		_refresh_queued = true
		_refresh.call_deferred()


func _refresh() -> void:
	_refresh_queued = false
	if not _is_open:
		return
	# Remember which row had focus so clicking through a list doesn't lose your place.
	var focused := get_viewport().gui_get_focus_owner()
	var focus_id: StringName = focused.get_meta(&"item_id", &"") if focused != null else &""
	var focus_in_fridge := focused != null and focused.get_parent() == _fridge_list

	_clear(_fridge_list)
	_clear(_backpack_list)
	for row in Cooking.fridge_contents():
		_fridge_list.add_child(_make_row(row[0], row[1], true))
	for row in _backpack_food():
		_backpack_list.add_child(_make_row(row[0], row[1], false))
	_empty_label.visible = _fridge_list.get_child_count() == 0

	if focus_id != &"":
		var list := _fridge_list if focus_in_fridge else _backpack_list
		for button in list.get_children():
			if button.get_meta(&"item_id") == focus_id:
				_focus.call_deferred(button)
				return
		_focus_first()


func _make_row(item: ItemData, count: int, in_fridge: bool) -> Button:
	var button := Button.new()
	button.text = "%s  x%d" % [item.display_name, count]
	button.icon = item.icon
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 9)
	button.set_meta(&"item_id", item.id)
	button.tooltip_text = "Take out" if in_fridge else "Put in the fridge"
	button.pressed.connect(_on_row_pressed.bind(item.id, in_fridge))
	button.focus_entered.connect(_show_info.bind(item, in_fridge))
	button.mouse_entered.connect(_show_info.bind(item, in_fridge))
	return button


func _on_row_pressed(item_id: StringName, in_fridge: bool) -> void:
	var whole_stack := Input.is_key_pressed(KEY_SHIFT)
	if in_fridge:
		var amount := Cooking.fridge_count(item_id) if whole_stack else 1
		if Cooking.take(item_id, amount) == 0:
			_info.text = "Your backpack is full."
	else:
		var amount := Inventory.count_of(item_id) if whole_stack else 1
		Cooking.store(item_id, amount)


func _show_info(item: ItemData, in_fridge: bool) -> void:
	var action := "Click: take one out" if in_fridge else "Click: put one in"
	_info.text = "%s - %s\n%s  (Shift: all)" % [item.display_name, item.description, action]


## Food in the backpack, one row per item, alphabetical.
func _backpack_food() -> Array:
	var rows := []
	var seen := {}
	for i in Inventory.size():
		var item := Inventory.item_at(i)
		if item == null or seen.has(item.id) or not Cooking.can_store(item):
			continue
		seen[item.id] = true
		rows.append([item, Inventory.count_of(item.id)])
	rows.sort_custom(func(a, b) -> bool: return a[0].display_name < b[0].display_name)
	return rows


func _focus_first() -> void:
	for list in [_fridge_list, _backpack_list]:
		if list.get_child_count() > 0:
			_focus.call_deferred(list.get_child(0))
			return
	_info.text = ""


## Deferred, so the row may have been redrawn away by the time it runs.
func _focus(button: Control) -> void:
	if is_instance_valid(button) and button.is_inside_tree():
		button.grab_focus()


func _clear(list: Container) -> void:
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()
