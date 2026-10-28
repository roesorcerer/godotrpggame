extends Node

## Dev-only smoke test for the kitchen: the fridge, recipes, the stove menu,
## and the Oven's stovetop and oven flows.
##   godot --headless --path . res://dev/cooking_smoke.tscn

const OVEN_SCENE := "res://props/ranchinside/oven/oven.tscn"
const FRIDGE_SCENE := "res://props/ranchinside/fridge/fridge.tscn"

var _failures: Array[String] = []
var _finished := false            ## set by the last line of _run(); a script error skips it


func _ready() -> void:
	await get_tree().process_frame
	await _run()
	if not _finished:
		_failures.append("_run() did not finish - see the script error above")
	if _failures.is_empty():
		print("COOKING SMOKE: PASS")
		get_tree().quit(0)
	else:
		for f in _failures:
			printerr("COOKING SMOKE FAIL: ", f)
		get_tree().quit(1)


func _check(cond: bool, label: String) -> void:
	if not cond:
		_failures.append(label)


func _run() -> void:
	_check_fridge_storage()
	await _check_fridge_door()
	_check_recipes()
	await _check_menu()
	await _check_stovetop()
	await _check_oven()
	_check_eating()
	_finished = true


## A new game's fridge has food; items move in and out; only food goes in.
func _check_fridge_storage() -> void:
	_check(Cooking.fridge_count(&"eggs") == Data.STARTING_FRIDGE[&"eggs"], "a new game starts with groceries")
	_check(not Cooking.fridge_is_empty(), "so the fridge isn't empty")
	var rows := Cooking.fridge_contents()
	_check(rows.size() == Data.STARTING_FRIDGE.size(), "the screen lists one row per food")
	_check(rows[0][0].display_name <= rows[-1][0].display_name, "alphabetical")

	Inventory.remove(&"eggs", Inventory.count_of(&"eggs"))
	_check(Cooking.take(&"eggs", 2) == 2, "take two eggs out")
	_check(Inventory.count_of(&"eggs") == 2, "they're in the backpack")
	_check(Cooking.fridge_count(&"eggs") == Data.STARTING_FRIDGE[&"eggs"] - 2, "and gone from the fridge")
	_check(Cooking.count_of(&"eggs") == Data.STARTING_FRIDGE[&"eggs"], "the stove counts both places")
	_check(Cooking.store(&"eggs", 2) == 2, "put them back")
	_check(Inventory.count_of(&"eggs") == 0, "backpack empty again")
	_check(Cooking.take(&"eggs", 99) == Data.STARTING_FRIDGE[&"eggs"], "can't take more than there is")
	Cooking.store(&"eggs", 99)

	_check(Inventory.count_of(&"axe") > 0, "the starting axe is in the backpack")
	_check(Cooking.store(&"axe") == 0, "the axe doesn't go in the fridge")

	# Cooking uses the fridge first, then the backpack.
	var eggs := Cooking.get_recipe(&"scrambled_eggs")
	GameState.fridge[&"eggs"] = 1
	Inventory.add(&"eggs", 3)
	Cooking.take_ingredients(eggs)
	_check(Cooking.fridge_count(&"eggs") == 0, "the fridge's egg went first")
	_check(Inventory.count_of(&"eggs") == 2, "then one from the backpack")
	Inventory.remove(&"eggs", 2)
	GameState.fridge = Data.STARTING_FRIDGE.duplicate()


## E opens the door; fully open shows the screen; closing it shuts the door.
func _check_fridge_door() -> void:
	var fridge: Fridge = load(FRIDGE_SCENE).instantiate()
	add_child(fridge)
	await get_tree().process_frame
	var anim := fridge.get_node("AnimationPlayer") as AnimationPlayer
	_check(fridge.get_prompt(null) == "Open fridge", "closed fridge offers to open")
	fridge.interact(null)
	_check(fridge.state == Fridge.State.OPEN, "door swings open")
	await anim.animation_finished
	_check(fridge.state == Fridge.State.STOCKED, "full fridge shows the food")
	var menu := _find_menu(FridgeMenu) as FridgeMenu
	_check(menu != null, "the fridge screen opens once the door is open")
	if menu == null:
		fridge.queue_free()
		return
	await get_tree().process_frame
	var list := menu.find_child("FridgeList") as VBoxContainer
	_check(list.get_child_count() == Cooking.fridge_contents().size(), "the screen lists what's inside")

	# Empty it from the screen: the shelves go bare while you watch.
	for item_id in GameState.fridge.keys():
		Cooking.take(item_id, 99)
	await get_tree().process_frame
	_check(fridge.state == Fridge.State.EMPTY, "taking everything shows the empty fridge")
	_check((menu.find_child("EmptyLabel") as Label).visible, "and the screen says so")

	menu.close()
	_check(fridge.state == Fridge.State.CLOSED, "closing the screen shuts the door")
	await anim.animation_finished
	_check(fridge.state == Fridge.State.FRIDGE, "back to the closed fridge")
	fridge.queue_free()
	for item_id in Data.STARTING_FRIDGE:
		Inventory.remove(item_id, Inventory.count_of(item_id))
	GameState.fridge = Data.STARTING_FRIDGE.duplicate()


## Every recipe loads, and every ingredient is a real item.
func _check_recipes() -> void:
	var known := Cooking.known()
	_check(known.size() >= 5, "the starter recipes load (%d)" % known.size())
	for recipe in known:
		_check(not recipe.ingredients.is_empty(), "%s has ingredients" % recipe.id)
		for item_id in recipe.ingredients:
			_check(Inventory.get_item(item_id) != null, "%s's '%s' is an item" % [recipe.id, item_id])

	var cheese := Cooking.get_recipe(&"grilled_cheese")
	_empty_out(cheese)
	_check(not Cooking.can_cook(cheese), "can't cook with nothing")
	_check(Cooking.missing(cheese) == {&"bread": 2, &"cheese": 1}, "knows what's missing")
	Inventory.add(&"bread", 2)
	_check(Cooking.missing(cheese) == {&"cheese": 1}, "missing shrinks as you gather")
	Inventory.add(&"cheese", 1)
	_check(Cooking.can_cook(cheese), "everything there: can cook")
	_check(Cooking.take_ingredients(cheese), "takes the ingredients")
	_check(Inventory.count_of(&"bread") == 0 and Inventory.count_of(&"cheese") == 0, "ingredients used up")
	_check(not Cooking.take_ingredients(cheese), "can't take them twice")

	GameState.set_flag(&"smoke_secret_recipe", false)
	var secret := RecipeData.new()
	secret.requires_flag = &"smoke_secret_recipe"
	_check(not secret.is_known(), "a gated recipe stays hidden")
	GameState.set_flag(&"smoke_secret_recipe")
	_check(secret.is_known(), "and shows once its flag is set")


## The menu lists recipes, pauses the clock, and hands back the one you pick.
func _check_menu() -> void:
	var oven := await _fresh_oven()
	var paused_before := GameClock.pause_depth()
	_check(oven.get_prompt(null) == "Cook", "idle stove offers to cook")
	oven.interact(null)
	await get_tree().process_frame
	var menu := _find_menu(CookingMenu) as CookingMenu
	_check(menu != null, "E opens the cooking menu")
	if menu == null:
		return
	_check(GameClock.pause_depth() == paused_before + 1, "the menu stops the clock")
	var list := menu.find_child("List") as VBoxContainer
	_check(list.get_child_count() == Cooking.known().size(), "every known recipe is listed")

	var eggs := Cooking.get_recipe(&"scrambled_eggs")
	_empty_out(eggs)
	menu._show(eggs)
	var cook_button := menu.find_child("CookButton") as Button
	_check(cook_button.disabled, "can't press Cook without the eggs")

	Inventory.add(&"eggs", 2)
	menu._show(eggs)
	_check(not cook_button.disabled, "Cook unlocks once you have them")
	cook_button.pressed.emit()
	await get_tree().process_frame
	_check(not is_instance_valid(menu), "the menu closes after choosing")
	_check(GameClock.pause_depth() == paused_before, "and gives the clock back")
	_check(oven.state == Oven.State.PAN_FOOD, "the chosen recipe goes in the pan")
	_check(oven.recipe == eggs, "the stove knows what's cooking")
	oven.queue_free()


## Pan -> burner -> cooks on the clock -> eat; survives leaving the room.
func _check_stovetop() -> void:
	var oven := await _fresh_oven()
	var anim := oven.get_node("AnimationPlayer") as AnimationPlayer
	var cheese := Cooking.get_recipe(&"grilled_cheese")
	_check(not oven.start(cheese), "can't start without ingredients")
	Inventory.add(&"bread", 2)
	Inventory.add(&"cheese", 1)
	_check(oven.start(cheese), "starts grilled cheese")
	_check(oven.state == Oven.State.PAN_FOOD, "food in the pan")
	_check(anim.current_animation == "oven_burneroff_food", "shows the pan")
	_check(oven.get_prompt(null) == "Turn on burner", "asks for the burner")
	_check(not oven.start(cheese), "can't start a second dish on a busy stove")

	oven.interact(null)
	_check(oven.state == Oven.State.COOKING, "burner on")
	_check(anim.current_animation == "oven_fourburners_on_food", "shows the flames")
	oven.interact(null)
	_check(oven.state == Oven.State.COOKING, "E while cooking changes nothing")

	# Leave the kitchen mid-cook, come back after it's done.
	oven.queue_free()
	await get_tree().process_frame
	GameClock.advance(cheese.cook_minutes)
	oven = await _fresh_oven(false)
	_check(oven.state == Oven.State.READY, "it finished while you were away")
	_check(oven.recipe == cheese, "and it's still grilled cheese")
	_check(oven.get_prompt(null) == "Take grilled cheese", "offers to take the dish")

	# Backpack full: the dish waits on the stove.
	var filler := 99 - Inventory.add(&"axe", 99)
	oven.interact(null)
	_check(oven.state == Oven.State.READY, "no room: it stays on the stove")
	Inventory.remove(&"axe", filler)

	var had := Inventory.count_of(&"grilled_cheese")
	oven.interact(null)
	_check(Inventory.count_of(&"grilled_cheese") == had + 1, "the dish goes in the backpack")
	_check(oven.state == Oven.State.IDLE and oven.recipe == null, "the stove is clear")
	_check(not GameState.props.has(&"oven_kitchen"), "an empty stove isn't saved")

	# On the clock, then left overnight.
	Inventory.add(&"eggs", 2)
	oven.start(Cooking.get_recipe(&"scrambled_eggs"))
	oven.interact(null)
	GameClock.advance(oven.recipe.cook_minutes - 1)
	_check(oven.state == Oven.State.COOKING, "not done a minute early")
	GameClock.advance(1)
	_check(oven.state == Oven.State.READY, "done on time")
	EventBus.day_started.emit(GameClock.day + 1)
	_check(oven.state == Oven.State.IDLE and oven.recipe == null, "nothing on the stove by morning")
	oven.queue_free()


## Door opens, food in, door shuts, bakes, eat.
func _check_oven() -> void:
	var oven := await _fresh_oven()
	var anim := oven.get_node("AnimationPlayer") as AnimationPlayer
	var pizza := Cooking.get_recipe(&"frozen_pizza")
	_check(pizza.method == RecipeData.Method.OVEN, "pizza is an oven recipe")
	Inventory.add(&"frozen_pizza", 1)
	_check(oven.start(pizza), "starts the pizza")
	_check(oven.state == Oven.State.OPENING, "the door opens")
	_check(oven.get_prompt(null) == "", "no prompt while the door moves")
	await anim.animation_finished
	_check(oven.state == Oven.State.CLOSING, "then shuts")
	await anim.animation_finished
	_check(oven.state == Oven.State.BAKING, "then it bakes")
	_check(oven.get_prompt(null) == "Baking...", "says it's baking")
	GameClock.advance(pizza.cook_minutes)
	_check(oven.state == Oven.State.READY, "pizza's ready")
	_check(anim.current_animation == "oven_fourburners_on", "ready pizza keeps the oven look")
	_check(oven.get_prompt(null) == "Take pizza", "the pizza comes out as pizza")
	oven.interact(null)
	_check(oven.state == Oven.State.IDLE, "taken out")
	_check(Inventory.count_of(&"pizza") >= 1, "pizza in the backpack")
	oven.queue_free()


## Every dish is food; eating one restores its Gas (Seats do the eating).
func _check_eating() -> void:
	for recipe in Cooking.known():
		var dish := Cooking.result_of(recipe)
		_check(dish != null and dish.is_edible(), "%s makes something edible" % recipe.id)
	_check(not Inventory.get_item(&"eggs").is_edible(), "raw eggs aren't a meal")

	Inventory.add(&"grilled_cheese", 1)
	var had := Inventory.count_of(&"grilled_cheese")
	GameState.gas = 0
	_check(Cooking.eat(&"grilled_cheese"), "eat a grilled cheese")
	_check(Inventory.count_of(&"grilled_cheese") == had - 1, "it's used up")
	_check(GameState.gas == Inventory.get_item(&"grilled_cheese").gas, "and restored its Gas")
	_check(not Cooking.eat(&"eggs"), "can't eat raw eggs")
	GameState.gas = GameState.gas_max


func _fresh_oven(clear_saved := true) -> Oven:
	if clear_saved:
		GameState.props.erase(&"oven_kitchen")
	var oven: Oven = load(OVEN_SCENE).instantiate()
	add_child(oven)
	await get_tree().process_frame
	return oven


func _empty_out(recipe: RecipeData) -> void:
	for item_id in recipe.ingredients:
		Inventory.remove(item_id, Inventory.count_of(item_id))
		GameState.fridge.erase(item_id)


func _hotbar_slot_of(item_id: StringName) -> int:
	for i in Data.HOTBAR_SIZE:
		var item := Inventory.item_at(i)
		if item != null and item.id == item_id:
			return i
	_failures.append("%s isn't in the hotbar" % item_id)
	return 0


func _find_menu(type: Variant) -> Node:
	for node in get_tree().root.get_children():
		if is_instance_of(node, type):
			return node
	return null
