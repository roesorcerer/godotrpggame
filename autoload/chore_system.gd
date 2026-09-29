extends Node

## Loads every ChoreData in data/chores/ and performs them. Adding a chore is a
## .tres file, never a code change.

const CHORE_DIR := "res://data/chores"

var _catalog: Dictionary = {}          ## StringName -> ChoreData


func _ready() -> void:
	_load_catalog()


func _load_catalog() -> void:
	_catalog.clear()
	var dir := DirAccess.open(CHORE_DIR)
	if dir == null:
		push_warning("ChoreSystem: no %s directory." % CHORE_DIR)
		return
	for file in dir.get_files():
		# Exported builds rename .tres to .remap; strip either.
		var name := file.trim_suffix(".remap")
		if not name.ends_with(".tres"):
			continue
		var res := load("%s/%s" % [CHORE_DIR, name])
		var chore := res as ChoreData
		if chore == null:
			push_warning("ChoreSystem: %s is not a ChoreData." % name)
			continue
		if chore.id == &"":
			push_warning("ChoreSystem: %s has no id." % name)
			continue
		_catalog[chore.id] = chore


func count() -> int:
	return _catalog.size()

func get_chore(chore_id: StringName) -> ChoreData:
	return _catalog.get(chore_id)

func all() -> Array:
	return _catalog.values()


## Everything in this room that is worth doing right now.
func available_in_room(room_id: StringName) -> Array:
	var out: Array = []
	for chore in _catalog.values():
		if chore.room == room_id and is_needed(chore):
			out.append(chore)
	return out


## A chore is needed when there is actually something to clean.
func is_needed(chore: ChoreData) -> bool:
	if chore.requires_flag != &"" and not GameState.has_flag(chore.requires_flag):
		return false
	match chore.kind:
		ChoreData.Kind.GRIME:
			return MessSystem.grime(chore.room) > 0
		ChoreData.Kind.CLUTTER:
			return MessSystem.clutter(chore.room) > 0
		_:
			return true


func can_afford(chore: ChoreData) -> bool:
	return GameState.gas >= chore.gas_cost


## Reasons a chore can't be done, for the prompt. "" means go ahead.
func blocked_reason(chore: ChoreData) -> String:
	if not can_afford(chore):
		return "Too tired"
	if chore.required_tool != &"" and not GameState.has_flag(chore.required_tool):
		return "Need a %s" % String(chore.required_tool).replace("_", " ")
	return ""


## Do it. Returns true if the work actually happened.
func perform(chore: ChoreData) -> bool:
	if not is_needed(chore) or blocked_reason(chore) != "":
		return false
	if not GameState.spend_gas(chore.gas_cost):
		return false

	match chore.kind:
		ChoreData.Kind.GRIME:
			MessSystem.add_grime(chore.room, -chore.relief)
		ChoreData.Kind.CLUTTER:
			MessSystem.add_clutter(chore.room, -chore.relief)
		ChoreData.Kind.CARE:
			GameState.doris["strain"] = clampi(
				int(GameState.doris["strain"]) + chore.strain_delta, 0, 100)

	if chore.money_reward != 0:
		GameState.add_money(chore.money_reward)

	GameClock.advance(chore.minutes)
	GameState.day_log.append({"kind": "chore", "id": chore.id, "name": chore.display_name})
	EventBus.chore_completed.emit(chore.id)
	return true
