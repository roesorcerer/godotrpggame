extends Node

## The backpack. Loads every ItemData in data/items/ and manages the slots in
## GameState.inventory, so the contents save and survive sleep. Slot 0 to
## Data.HOTBAR_SIZE - 1 are the hotbar. UI and gameplay only call this API and
## listen for EventBus.inventory_changed - they never edit the slots directly.

const ITEM_DIR := "res://data/items"

var selected := 0                       ## hotbar slot the player is holding

var _catalog: Dictionary = {}           ## StringName -> ItemData


func _ready() -> void:
	_load_catalog()
	_fit_slots()
	# A new game (nothing saved yet) starts with the tools in the hotbar.
	if GameState.inventory.all(func(slot): return slot.is_empty()):
		for item_id in Data.STARTING_ITEMS:
			add(item_id)


func _load_catalog() -> void:
	_catalog.clear()
	var dir := DirAccess.open(ITEM_DIR)
	if dir == null:
		push_warning("Inventory: no %s directory." % ITEM_DIR)
		return
	for file in dir.get_files():
		# Exported builds rename .tres to .remap; strip either.
		var p_name := file.trim_suffix(".remap")
		if not p_name.ends_with(".tres"):
			continue
		var item := load("%s/%s" % [ITEM_DIR, p_name]) as ItemData
		if item == null:
			push_warning("Inventory: %s is not an ItemData." % p_name)
			continue
		if item.id == &"":
			push_warning("Inventory: %s has no id." % p_name)
			continue
		_catalog[item.id] = item


## Grow (never shrink) the slot list to the current backpack size.
func _fit_slots() -> void:
	while GameState.inventory.size() < GameState.backpack_size:
		GameState.inventory.append({})


func get_item(item_id: StringName) -> ItemData:
	return _catalog.get(item_id)

func all_items() -> Array:
	return _catalog.values()


## --- reading slots ----------------------------------------------------------

func size() -> int:
	return GameState.backpack_size

## {} for an empty slot, else {"id": String, "count": int}.
func get_slot(index: int) -> Dictionary:
	if index < 0 or index >= GameState.inventory.size():
		return {}
	return GameState.inventory[index]

func item_at(index: int) -> ItemData:
	var slot := get_slot(index)
	return get_item(StringName(slot["id"])) if not slot.is_empty() else null

func count_at(index: int) -> int:
	return int(get_slot(index).get("count", 0))

func count_of(item_id: StringName) -> int:
	var total := 0
	for slot in GameState.inventory:
		if not slot.is_empty() and StringName(slot["id"]) == item_id:
			total += int(slot["count"])
	return total

func has(item_id: StringName, amount := 1) -> bool:
	return count_of(item_id) >= amount

func selected_item() -> ItemData:
	return item_at(selected)


## --- changing slots ---------------------------------------------------------

## Adds items, topping up existing stacks first, then empty slots.
## Returns how many didn't fit (0 = all of them went in).
func add(item_id: StringName, amount := 1) -> int:
	var item := get_item(item_id)
	if item == null:
		push_warning("Inventory: no item '%s' in %s." % [item_id, ITEM_DIR])
		return amount
	_fit_slots()
	var left := amount
	for i in size():
		var slot: Dictionary = GameState.inventory[i]
		if left > 0 and not slot.is_empty() and StringName(slot["id"]) == item_id:
			var room := item.max_stack - int(slot["count"])
			var moved := mini(room, left)
			slot["count"] = int(slot["count"]) + moved
			left -= moved
	for i in size():
		if left > 0 and GameState.inventory[i].is_empty():
			var moved := mini(item.max_stack, left)
			GameState.inventory[i] = {"id": String(item_id), "count": moved}
			left -= moved
	if left < amount:
		EventBus.item_added.emit(item_id, amount - left)
		EventBus.inventory_changed.emit()
	return left


## Takes `amount` items out, from the last slots first. False (and nothing
## removed) if there aren't enough.
func remove(item_id: StringName, amount := 1) -> bool:
	if not has(item_id, amount):
		return false
	var left := amount
	for i in range(size() - 1, -1, -1):
		var slot: Dictionary = GameState.inventory[i]
		if left > 0 and not slot.is_empty() and StringName(slot["id"]) == item_id:
			var taken := mini(int(slot["count"]), left)
			slot["count"] = int(slot["count"]) - taken
			left -= taken
			if int(slot["count"]) <= 0:
				GameState.inventory[i] = {}
	EventBus.inventory_changed.emit()
	return true


## Drag and drop: merge into a stack of the same item, otherwise swap.
func move(from: int, to: int) -> void:
	if from == to or from < 0 or to < 0 or from >= size() or to >= size():
		return
	var a: Dictionary = GameState.inventory[from]
	var b: Dictionary = GameState.inventory[to]
	if not a.is_empty() and not b.is_empty() and a["id"] == b["id"]:
		var item := get_item(StringName(a["id"]))
		var moved := mini(item.max_stack - int(b["count"]), int(a["count"]))
		b["count"] = int(b["count"]) + moved
		a["count"] = int(a["count"]) - moved
		if int(a["count"]) <= 0:
			GameState.inventory[from] = {}
	else:
		GameState.inventory[from] = b
		GameState.inventory[to] = a
	EventBus.inventory_changed.emit()


func select(index: int) -> void:
	selected = posmod(index, Data.HOTBAR_SIZE)
	EventBus.hotbar_selected.emit(selected)


## Throw away whatever is in a slot (the backpack's trash can).
func discard(index: int) -> void:
	if index < 0 or index >= size() or GameState.inventory[index].is_empty():
		return
	GameState.inventory[index] = {}
	EventBus.inventory_changed.emit()


## The backpack's Organize button: merges stacks and sorts everything past the
## hotbar by category, then name. The hotbar is left as the player set it up.
func sort() -> void:
	var counts := {}                       ## id -> total, for slots past the hotbar
	for i in range(Data.HOTBAR_SIZE, size()):
		var slot: Dictionary = GameState.inventory[i]
		if not slot.is_empty():
			counts[slot["id"]] = int(counts.get(slot["id"], 0)) + int(slot["count"])
			GameState.inventory[i] = {}
	var ids := counts.keys()
	ids.sort_custom(func(a, b):
		var ia := get_item(StringName(a))
		var ib := get_item(StringName(b))
		if ia.category != ib.category:
			return ia.category < ib.category
		return ia.display_name < ib.display_name)
	var next := Data.HOTBAR_SIZE
	for id in ids:
		var left := int(counts[id])
		var max_stack := get_item(StringName(id)).max_stack
		while left > 0 and next < size():
			GameState.inventory[next] = {"id": id, "count": mini(left, max_stack)}
			left -= max_stack
			next += 1
	EventBus.inventory_changed.emit()


## Bigger backpack (e.g. bought from a shop).
func upgrade(new_size: int) -> void:
	GameState.backpack_size = clampi(new_size, GameState.backpack_size, Data.BACKPACK_MAX_SIZE)
	_fit_slots()
	EventBus.inventory_changed.emit()
