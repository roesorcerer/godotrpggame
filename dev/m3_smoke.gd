extends Node

## Dev-only smoke test for M3: the save file and world-state props.
##   godot --headless --path . res://dev/m3_smoke.tscn
## Uses the real user://save.dat, so it backs up any existing save first and
## puts it back afterwards.

const BACKUP_PATH := "user://save.dat.smoke_backup"

var _failures: Array[String] = []
var _finished := false            ## set by the last line of _run(); a script error skips it


func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var dir := DirAccess.open("user://")
	var had_save := SaveSystem.has_save()
	if had_save:
		dir.copy(SaveSystem.SAVE_PATH, BACKUP_PATH)

	await _run()

	SaveSystem.delete_save()
	if had_save:
		dir.rename(BACKUP_PATH.get_file(), SaveSystem.SAVE_PATH.get_file())
	if not _finished:
		_failures.append("_run() did not finish - see the script error above")
	if _failures.is_empty():
		print("M3 SMOKE: PASS")
		get_tree().quit(0)
	else:
		for f in _failures:
			printerr("M3 SMOKE FAIL: ", f)
		get_tree().quit(1)


func _check(cond: bool, label: String) -> void:
	if not cond:
		_failures.append(label)


func _run() -> void:
	# --- everything that matters goes into the blob and back out ---
	GameClock.day = 9
	GameClock.minutes = 300
	GameState.money = 137
	GameState.gas = 42
	GameState.gas_max = 90
	GameState.set_flag(&"met_hal")
	GameState.props[&"fireplace_living_room"] = Fireplace.State.LIT
	GameState.npcs[&"oscar"] = {"level": 2, "met": true}
	GameState.doris["mood"] = 33
	GameState.quests[&"go_to_town"] = "active"
	GameState.chores_done = ["dishes"]
	GameState.skipped_family_dinner = true
	Inventory.add(&"firewood", 5)
	GameState.fridge = {&"eggs": 3}


	_check(SaveSystem.save_game(), "save_game wrote the file")
	_check(SaveSystem.has_save(), "the save exists on disk")
	_check(not FileAccess.file_exists(SaveSystem.TEMP_PATH), "no temp file left behind")

	# Trash everything, then load it back.
	GameState.from_dict({})
	_check(GameState.money == 0 and Inventory.count_of(&"firewood") == 0, "state was wiped")
	var data := SaveSystem.read_save()
	_check(not data.is_empty(), "read_save got the dictionary back")
	GameState.from_dict(data)

	_check(GameClock.day == 9 and GameClock.minutes == 300, "clock survives")
	_check(GameState.money == 137, "money survives")
	_check(GameState.gas == 42 and GameState.gas_max == 90, "gas survives")
	_check(GameState.has_flag(&"met_hal"), "flags survive (StringName keys intact)")
	_check(GameState.props.get(&"fireplace_living_room") == Fireplace.State.LIT, "props survive")
	_check(GameState.npcs.get(&"oscar", {}).get("level") == 2, "npc friendship survives")
	_check(Mom.mood() == 33, "Mom's mood survives")
	_check(GameState.quests.get(&"go_to_town") == "active", "quests survive")
	_check(GameState.chores_done.has("dishes"), "today's chores survive")
	_check(GameState.skipped_family_dinner, "the dinner flag survives")
	_check(Inventory.count_of(&"firewood") == 5, "inventory survives, got %d" % Inventory.count_of(&"firewood"))

	_check(GameState.fridge == {&"eggs": 3}, "the fridge survives, got %s" % GameState.fridge)
	_check(typeof(GameClock.day) == TYPE_INT, "ints stay ints (no JSON floats)")

	# --- a corrupt file is refused, not crashed on ---
	var f := FileAccess.open(SaveSystem.SAVE_PATH, FileAccess.WRITE)
	f.store_string("not a save")
	f.close()
	_check(SaveSystem.read_save().is_empty(), "a garbage file reads as no save")

	# --- sleeping autosaves ---
	SaveSystem.delete_save()
	GameClock.end_day(false)
	_check(SaveSystem.has_save(), "going to bed autosaved")
	_check(int(SaveSystem.read_save().get("day", 0)) == GameClock.day, "the autosave is the new morning")

	await _check_fireplace()
	_finished = true


## Off -> wood (uses one firewood) -> lit, kept in GameState, out by morning.
func _check_fireplace() -> void:
	GameState.props.erase(&"fireplace_living_room")
	var fireplace: Fireplace = load("res://props/ranchinside/fireplace/fireplace.tscn").instantiate()
	add_child(fireplace)
	await get_tree().process_frame
	var anim := fireplace.get_node("AnimationPlayer") as AnimationPlayer

	_check(fireplace.state == Fireplace.State.OFF, "fireplace starts off")
	_check(anim.current_animation == "off", "shows the empty grate")

	Inventory.remove(&"firewood", Inventory.count_of(&"firewood"))
	_check(fireplace.get_prompt(null) == "Needs firewood", "asks for wood when you have none")
	fireplace.interact(null)
	_check(fireplace.state == Fireplace.State.OFF, "no wood, no change")

	Inventory.add(&"firewood", 2)
	_check(fireplace.get_prompt(null) == "Add firewood", "offers to add wood")
	fireplace.interact(null)
	_check(fireplace.state == Fireplace.State.WOOD, "wood added")
	_check(Inventory.count_of(&"firewood") == 1, "used one firewood")
	_check(anim.current_animation == "wood", "shows the logs")

	_check(fireplace.get_prompt(null) == "Light fire", "offers to light it")
	fireplace.interact(null)
	_check(fireplace.state == Fireplace.State.LIT, "fire lit")
	_check(anim.current_animation == "lit", "shows the flames")
	_check(not fireplace.can_interact(null), "a lit fire has nothing to offer")

	# A fresh instance (re-entering the room) reads the saved state.
	fireplace.queue_free()
	await get_tree().process_frame
	fireplace = load("res://props/ranchinside/fireplace/fireplace.tscn").instantiate()
	add_child(fireplace)
	await get_tree().process_frame
	_check(fireplace.state == Fireplace.State.LIT, "the fire is still lit when you come back")

	EventBus.day_started.emit(GameClock.day + 1)
	_check(fireplace.state == Fireplace.State.OFF, "it burns out overnight")
	fireplace.queue_free()
