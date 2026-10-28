class_name CookingMenu
extends CanvasLayer

## The stove's recipe menu: known recipes on the left, the selected one's
## ingredients and instructions on the right. Recipes you're missing
## ingredients for stay listed but can't be cooked. Time stops while it's
## open. The stove opens it with open() and listens for `chosen`; the menu
## frees itself when it closes.

signal chosen(recipe: RecipeData)
signal closed()

const HAVE_COLOR := Color(0.75, 0.78, 0.73)
const MISSING_COLOR := Color(1.0, 0.55, 0.5)
const METHOD_TEXT := {
	RecipeData.Method.STOVETOP: "Stovetop",
	RecipeData.Method.OVEN: "Oven",
}

@onready var _list: VBoxContainer = %List
@onready var _name: Label = %RecipeName
@onready var _ingredients: VBoxContainer = %Ingredients
@onready var _instructions: Label = %Instructions
@onready var _cook_button: Button = %CookButton

var _selected: RecipeData = null
var _is_open := false


func _ready() -> void:
	_cook_button.pressed.connect(_on_cook_pressed)


func open() -> void:
	_is_open = true
	GameClock.request_pause()
	_fill_list()


func close() -> void:
	if not _is_open:
		return
	_is_open = false
	GameClock.release_pause()
	closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("inventory"):
		get_viewport().set_input_as_handled()
		close()


func _fill_list() -> void:
	for child in _list.get_children():
		child.queue_free()
	var recipes := Cooking.known()
	if recipes.is_empty():
		_show(null)
		return
	for recipe in recipes:
		var button := Button.new()
		button.text = recipe.display_name
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_font_size_override("font_size", 9)
		if not Cooking.can_cook(recipe):
			button.modulate = Color(1, 1, 1, 0.55)
		button.focus_entered.connect(_show.bind(recipe))
		button.mouse_entered.connect(button.grab_focus)
		button.pressed.connect(_on_recipe_pressed.bind(recipe))
		_list.add_child(button)
	(_list.get_child(0) as Button).grab_focus()
	_show(recipes[0])


func _show(recipe: RecipeData) -> void:
	_selected = recipe
	for child in _ingredients.get_children():
		child.queue_free()
	if recipe == null:
		_name.text = "You don't know any recipes."
		_instructions.text = ""
		_cook_button.disabled = true
		return

	_name.text = "%s  ·  %s, %d min" % [recipe.display_name, METHOD_TEXT[recipe.method], recipe.cook_minutes]
	var short := Cooking.missing(recipe)
	for item_id in recipe.ingredients:
		var item := Inventory.get_item(item_id)
		var label := Label.new()
		label.add_theme_font_size_override("font_size", 9)
		var item_name: String = item.display_name if item != null else String(item_id)
		label.text = "%s  %d/%d" % [item_name, Cooking.count_of(item_id), recipe.ingredients[item_id]]
		label.add_theme_color_override("font_color", MISSING_COLOR if short.has(item_id) else HAVE_COLOR)
		_ingredients.add_child(label)
	var dish := Cooking.result_of(recipe)
	_instructions.text = recipe.instructions
	if dish != null and dish.is_edible():
		_instructions.text += "\n\nMakes %s  (+%d Gas)" % [dish.display_name.to_lower(), dish.gas]
	_cook_button.disabled = not short.is_empty()
	_cook_button.text = "Cook" if short.is_empty() else "Missing ingredients"


## Space/Enter on a recipe in the list cooks it straight away, if it can.
func _on_recipe_pressed(recipe: RecipeData) -> void:
	_show(recipe)
	if Cooking.can_cook(recipe):
		_on_cook_pressed()


func _on_cook_pressed() -> void:
	if _selected == null or not Cooking.can_cook(_selected):
		return
	var recipe := _selected
	close()
	chosen.emit(recipe)
