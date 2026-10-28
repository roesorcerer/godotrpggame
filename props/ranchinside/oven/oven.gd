class_name Oven
extends Interactable

## The kitchen stove. E on an idle stove opens the cooking menu; picking a
## recipe uses its ingredients and starts it. After that, E always does the
## next step and the prompt says what it is:
##
##   IDLE      "Cook"  -> menu -> pick a recipe
##               stovetop recipe:                                -> PAN_FOOD
##               oven recipe:                                    -> OPENING
##   PAN_FOOD  "Turn on burner"                                  -> COOKING
##   COOKING   "Cooking..." - waits the recipe's cook_minutes    -> READY
##   OPENING   door swings open, food goes in (no prompt)        -> CLOSING
##   CLOSING   door swings shut (no prompt)                      -> BAKING
##   BAKING    "Baking..." - waits the recipe's cook_minutes     -> READY
##   READY     "Take <dish>" - the dish goes in the backpack     -> IDLE
##             (backpack full: it waits on the stove)
##
## Food on the stove is remembered in GameState.props (like the fireplace),
## so leaving the kitchen mid-cook doesn't lose it.

enum State {IDLE, PAN_FOOD, COOKING, OPENING, CLOSING, BAKING, READY}

## AnimationPlayer animation for each state. READY keeps showing whatever
## the food was cooking in - see _animation_for().
const ANIMATIONS := {
	State.IDLE: &"oven",
	State.PAN_FOOD: &"oven_burneroff_food",
	State.COOKING: &"oven_fourburners_on_food",
	State.OPENING: &"oven_open",
	State.CLOSING: &"oven_closed",
	State.BAKING: &"oven_fourburners_on",   # placeholder until there's oven-on art
}

const MENU_SCENE := preload("res://ui/cooking/cooking_menu.tscn")

## Where the stove's state is stored. Give each stove its own key.
@export var state_key: StringName = &"oven_kitchen"

@onready var _animation_player: AnimationPlayer = $AnimationPlayer

## What's cooking, or null when the stove is empty.
var recipe: RecipeData = null

## The day-minute (GameClock.minutes) when the food will be ready.
var _done_at := 0

var state: State = State.IDLE:
	set(value):
		state = value
		_save()
		if is_node_ready():
			_animation_player.play(_animation_for(state))


func _ready() -> void:
	super()
	_animation_player.animation_finished.connect(_on_animation_finished)
	EventBus.minute_ticked.connect(_on_minute_ticked)
	EventBus.day_started.connect(_on_day_started)
	_load()
	_animation_player.play(_animation_for(state))


func get_prompt(_by: Node2D) -> String:
	match state:
		State.IDLE:
			return "Cook"
		State.PAN_FOOD:
			return "Turn on burner"
		State.COOKING:
			return "Cooking..."
		State.BAKING:
			return "Baking..."
		State.READY:
			var dish := Cooking.result_of(recipe)
			return "Take %s" % (dish.display_name.to_lower() if dish != null else "food")
	return ""   # mid-swing: no prompt


func _on_interact(_by: Node2D) -> void:
	match state:
		State.IDLE:
			open_menu()
		State.PAN_FOOD:
			_done_at = GameClock.minutes + recipe.cook_minutes
			state = State.COOKING
		State.READY:
			_take_dish()


func open_menu() -> void:
	var menu: CookingMenu = MENU_SCENE.instantiate()
	get_tree().root.add_child(menu)
	menu.chosen.connect(start)
	menu.open()


## Uses the recipe's ingredients and puts it on (or in) the stove.
## False if the stove is busy or something is missing.
func start(new_recipe: RecipeData) -> bool:
	if state != State.IDLE or not Cooking.take_ingredients(new_recipe):
		return false
	recipe = new_recipe
	match recipe.method:
		RecipeData.Method.STOVETOP:
			state = State.PAN_FOOD
		RecipeData.Method.OVEN:
			# The oven heats while the door swings, so the clock starts now.
			_done_at = GameClock.minutes + recipe.cook_minutes
			state = State.OPENING
	return true


## The door finished swinging: food in, door shut, start baking.
func _on_animation_finished(_anim: StringName) -> void:
	match state:
		State.OPENING:
			state = State.CLOSING
		State.CLOSING:
			state = State.BAKING
			_check_done(GameClock.minutes)


func _on_minute_ticked(day_minutes: int) -> void:
	_check_done(day_minutes)


func _check_done(day_minutes: int) -> void:
	if state in [State.COOKING, State.BAKING] and day_minutes >= _done_at:
		state = State.READY


## Nobody leaves food on overnight; it's gone by morning.
func _on_day_started(_day: int) -> void:
	recipe = null
	state = State.IDLE


## The finished dish goes in the backpack. If there's no room it stays on
## the stove until there is.
func _take_dish() -> void:
	if Inventory.add(recipe.result) > 0:
		EventBus.notice.emit("No room in your backpack.")
		return
	recipe = null
	state = State.IDLE


## READY looks like whatever the food was cooking in.
func _animation_for(s: State) -> StringName:
	if s == State.READY:
		var oven_food := recipe != null and recipe.method == RecipeData.Method.OVEN
		return ANIMATIONS[State.BAKING] if oven_food else ANIMATIONS[State.COOKING]
	return ANIMATIONS[s]


## Only food on the stove is worth remembering. Leaving mid-swing counts as
## baking: the ingredients are already used.
func _save() -> void:
	if recipe == null or state == State.IDLE:
		GameState.props.erase(state_key)
		return
	var saved_state := State.BAKING if state in [State.OPENING, State.CLOSING] else state
	GameState.props[state_key] = {"state": saved_state, "recipe": recipe.id, "done_at": _done_at}


func _load() -> void:
	var saved: Dictionary = GameState.props.get(state_key, {})
	recipe = Cooking.get_recipe(saved.get("recipe", &""))
	if recipe == null:
		state = State.IDLE
		return
	_done_at = int(saved.get("done_at", 0))
	state = int(saved.get("state", State.IDLE)) as State
	# Time may have passed while the player was in another room.
	_check_done(GameClock.minutes)
