extends Node

## Loads every ChoreData in data/chores/ and runs the daily list. Adding a
## chore is a .tres file, never a code change.
##
## Each day a few chores are on the list (by weekday). Doing one spends Gas and
## time and lifts Mom's mood; at bedtime every chore still undone costs mood.

const CHORE_DIR := "res://data/chores"

var _catalog: Dictionary = {}          ## StringName -> ChoreData


func _ready() -> void:
	_load_catalog()
	EventBus.day_started.connect(func(_d): EventBus.chores_changed.emit())


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
		var chore := load("%s/%s" % [CHORE_DIR, name]) as ChoreData
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


## --- today's list ---------------------------------------------------------

func is_scheduled_today(chore: ChoreData) -> bool:
	if chore.requires_flag != &"" and not GameState.has_flag(chore.requires_flag):
		return false
	return chore.weekdays.is_empty() or chore.weekdays.has(GameClock.weekday())

func is_done(chore: ChoreData) -> bool:
	return GameState.chores_done.has(String(chore.id))

## On today's list and not done yet.
func is_needed(chore: ChoreData) -> bool:
	return is_scheduled_today(chore) and not is_done(chore)

func todays_list() -> Array:
	return _catalog.values().filter(is_scheduled_today)

func remaining() -> Array:
	return _catalog.values().filter(is_needed)

func available_in_room(room_id: StringName) -> Array:
	return remaining().filter(func(c): return c.room == room_id)


## --- doing one ------------------------------------------------------------

## Reasons a chore can't be done, for the prompt. "" means go ahead.
func blocked_reason(chore: ChoreData) -> String:
	if GameState.gas < chore.gas_cost:
		return "Too tired"
	return ""


## Do it. Returns true if the work actually happened.
func perform(chore: ChoreData) -> bool:
	if not is_needed(chore) or blocked_reason(chore) != "":
		return false
	if not GameState.spend_gas(chore.gas_cost):
		return false

	credit(chore)
	# Last: running the clock out ends the day, which settles the list.
	GameClock.advance(chore.minutes)
	return true


## Tick a chore off without its own Gas and time cost - for when another
## system did the work (studying at the table counts as schoolwork).
## Returns false if it wasn't on today's list or was already done.
func credit(chore: ChoreData) -> bool:
	if chore == null or not is_needed(chore):
		return false
	GameState.chores_done.append(String(chore.id))
	Mom.change(chore.mood)
	GameState.day_log.append({"kind": "chore", "id": chore.id, "name": chore.display_name})
	EventBus.chore_completed.emit(chore.id)
	EventBus.chores_changed.emit()
	return true


## --- bedtime --------------------------------------------------------------

## Called by GameClock.end_day() before the day rolls over. Charges Mom's mood
## for what was skipped and writes the outcome into the day summary.
func close_day(summary: Dictionary) -> void:
	var missed := remaining()
	var cost := 0
	for chore in missed:
		cost += chore.mood
	Mom.change(-cost)

	summary["chores_done"] = GameState.chores_done.size()
	summary["chores_missed"] = missed.map(func(c): return c.display_name)
	summary["mood"] = Mom.mood()
	summary["mood_change"] = Mom.mood() - int(GameState.doris.get("mood_at_dawn", Mom.mood()))
