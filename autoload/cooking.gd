extends Node

## The recipe book. Loads every RecipeData in data/recipes/ and answers the
## stove's questions: which recipes the player knows, what they're missing,
## and taking the ingredients when they cook. It also owns the kitchen
## fridge (GameState.fridge): ingredients count from the fridge and the
## backpack together, and cooking uses the fridge's first.
##
## In debug builds F7 puts a bag of every ingredient in the fridge, so the
## kitchen can be tested before groceries exist.

const RECIPE_DIR := "res://data/recipes"

var _recipes: Array[RecipeData] = []
var _by_id: Dictionary = {}             ## StringName -> RecipeData


func _ready() -> void:
	_load_recipes()


func _load_recipes() -> void:
	_recipes.clear()
	_by_id.clear()
	var dir := DirAccess.open(RECIPE_DIR)
	if dir == null:
		push_warning("Cooking: no %s directory." % RECIPE_DIR)
		return
	for file in dir.get_files():
		# Exported builds rename .tres to .remap; strip either.
		var name := file.trim_suffix(".remap")
		if not name.ends_with(".tres"):
			continue
		var recipe := load("%s/%s" % [RECIPE_DIR, name]) as RecipeData
		if recipe == null or recipe.id == &"":
			push_warning("Cooking: %s is not a RecipeData with an id." % name)
			continue
		for item_id in recipe.ingredients:
			if Inventory.get_item(item_id) == null:
				push_warning("Cooking: %s needs '%s', which isn't in data/items/." % [name, item_id])
		if result_of(recipe) == null:
			push_warning("Cooking: %s makes '%s', which isn't in data/items/." % [name, recipe.result])
		_recipes.append(recipe)
		_by_id[recipe.id] = recipe
	_recipes.sort_custom(func(a: RecipeData, b: RecipeData) -> bool:
		return a.display_name < b.display_name)


func get_recipe(recipe_id: StringName) -> RecipeData:
	return _by_id.get(recipe_id)


## The item a recipe makes (null if its `result` is missing or wrong).
func result_of(recipe: RecipeData) -> ItemData:
	return Inventory.get_item(recipe.result) if recipe != null else null


## Recipes the player has learned, alphabetical.
func known() -> Array[RecipeData]:
	var list: Array[RecipeData] = []
	for recipe in _recipes:
		if recipe.is_known():
			list.append(recipe)
	return list


## How many of an ingredient the player can reach: fridge plus backpack.
func count_of(item_id: StringName) -> int:
	return fridge_count(item_id) + Inventory.count_of(item_id)


## Item id -> how many more are needed. Empty = ready to cook.
func missing(recipe: RecipeData) -> Dictionary:
	var short := {}
	for item_id in recipe.ingredients:
		var need: int = recipe.ingredients[item_id] - count_of(item_id)
		if need > 0:
			short[item_id] = need
	return short


func can_cook(recipe: RecipeData) -> bool:
	return recipe.is_known() and missing(recipe).is_empty()


## Uses up the ingredients. False (and nothing taken) if any are missing.
func take_ingredients(recipe: RecipeData) -> bool:
	if not can_cook(recipe):
		return false
	for item_id in recipe.ingredients:
		var need: int = recipe.ingredients[item_id]
		var from_fridge := mini(need, fridge_count(item_id))
		_fridge_add(item_id, -from_fridge)
		if need > from_fridge:
			Inventory.remove(item_id, need - from_fridge)
	EventBus.fridge_changed.emit()
	return true


## --- eating ----------------------------------------------------------------

## Eats one from the backpack (Seats call this - you eat sitting down): restores Gas, says its line. False if there
## isn't one or it isn't food.
func eat(item_id: StringName) -> bool:
	var item := Inventory.get_item(item_id)
	if item == null or not item.is_edible() or not Inventory.remove(item_id):
		return false
	GameState.restore_gas(item.gas)
	if item.eat_line != "":
		EventBus.notice.emit(item.eat_line)
	return true


## --- the fridge ------------------------------------------------------------

func fridge_count(item_id: StringName) -> int:
	return int(GameState.fridge.get(item_id, 0))


## What's in the fridge as [ItemData, count] pairs, alphabetical.
func fridge_contents() -> Array:
	var rows := []
	for item_id in GameState.fridge:
		var item := Inventory.get_item(item_id)
		if item != null and fridge_count(item_id) > 0:
			rows.append([item, fridge_count(item_id)])
	rows.sort_custom(func(a, b) -> bool: return a[0].display_name < b[0].display_name)
	return rows


func fridge_is_empty() -> bool:
	return fridge_contents().is_empty()


## Only food goes in the fridge.
func can_store(item: ItemData) -> bool:
	return item != null and item.category == Enum.ItemCategory.FOOD


## Backpack -> fridge. Returns how many actually moved.
func store(item_id: StringName, amount := 1) -> int:
	if not can_store(Inventory.get_item(item_id)):
		return 0
	amount = mini(amount, Inventory.count_of(item_id))
	if amount <= 0 or not Inventory.remove(item_id, amount):
		return 0
	_fridge_add(item_id, amount)
	EventBus.fridge_changed.emit()
	return amount


## Fridge -> backpack. Returns how many actually moved (less if the
## backpack is full).
func take(item_id: StringName, amount := 1) -> int:
	amount = mini(amount, fridge_count(item_id))
	if amount <= 0:
		return 0
	var didnt_fit := Inventory.add(item_id, amount)
	var moved := amount - didnt_fit
	_fridge_add(item_id, -moved)
	EventBus.fridge_changed.emit()
	return moved


func _fridge_add(item_id: StringName, amount: int) -> void:
	var count := fridge_count(item_id) + amount
	if count > 0:
		GameState.fridge[item_id] = count
	else:
		GameState.fridge.erase(item_id)


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build() or not event is InputEventKey or not event.pressed or event.echo:
		return
	if (event as InputEventKey).physical_keycode == KEY_F7:
		for recipe in _recipes:
			for item_id in recipe.ingredients:
				_fridge_add(item_id, recipe.ingredients[item_id])
		EventBus.fridge_changed.emit()
		EventBus.notice.emit("Groceries added to the fridge.")
