class_name Fridge
extends Interactable

## The kitchen fridge. E opens the door; once it's open, the fridge screen
## shows what's inside (GameState.fridge, managed by Cooking). Closing the
## screen swings the door shut. Five looks, one per state:
##  FRIDGE  - closed, the resting look. E opens it.
##  OPEN    - door swinging open (plays once, then STOCKED or EMPTY).
##  STOCKED - open, food inside.
##  EMPTY   - open, nothing to eat.
##  CLOSED  - door swinging shut (plays once, then FRIDGE).
## The door always starts shut, so the state isn't saved - the food is.

enum State {FRIDGE, OPEN, CLOSED, STOCKED, EMPTY}

## AnimationPlayer animations
const ANIMATIONS := {
	State.FRIDGE: &"fridge",
	State.OPEN: &"fridge_stocked_open",
	State.CLOSED: &"fridge_stocked_closed",
	State.STOCKED: &"fridge_stocked",
	State.EMPTY: &"fridge_empty",
}

const MENU_SCENE := preload("res://ui/fridge/fridge_menu.tscn")

@onready var _animation_player: AnimationPlayer = $AnimationPlayer

var state: State = State.FRIDGE:
	set(value):
		state = value
		if is_node_ready():
			_animation_player.play(ANIMATIONS[state])


func _ready() -> void:
	super()
	_animation_player.animation_finished.connect(_on_animation_finished)
	EventBus.fridge_changed.connect(_on_fridge_changed)
	_animation_player.play(ANIMATIONS[state])


func get_prompt(_by: Node2D) -> String:
	match state:
		State.FRIDGE:
			return "Open fridge"
		State.STOCKED, State.EMPTY:
			return "Close fridge"
	return ""   # mid-swing: no prompt


func _on_interact(_by: Node2D) -> void:
	match state:
		State.FRIDGE:
			state = State.OPEN
		State.STOCKED, State.EMPTY:
			state = State.CLOSED


## When the door finishes swinging, switch to the still picture. Fully
## open = time to look inside.
func _on_animation_finished(_anim: StringName) -> void:
	match state:
		State.OPEN:
			state = _open_look()
			open_menu()
		State.CLOSED:
			state = State.FRIDGE


func open_menu() -> void:
	var menu: FridgeMenu = MENU_SCENE.instantiate()
	get_tree().root.add_child(menu)
	menu.closed.connect(_on_menu_closed)
	menu.open()


func _on_menu_closed() -> void:
	if state in [State.STOCKED, State.EMPTY]:
		state = State.CLOSED


## Taking the last thing out shows the empty shelves straight away.
func _on_fridge_changed() -> void:
	if state in [State.STOCKED, State.EMPTY]:
		state = _open_look()


## Which open picture to show, from what's actually inside.
func _open_look() -> State:
	return State.EMPTY if Cooking.fridge_is_empty() else State.STOCKED
