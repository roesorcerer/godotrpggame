class_name Fireplace
extends Interactable

## The living-room fireplace. Three looks, one per state:
##   OFF  - empty grate. E with firewood in the backpack loads it (uses 1).
##   WOOD - logs stacked, not burning. E lights it.
##   LIT  - burning. Nothing more to do until it burns out overnight.
## The state lives in GameState.props under `state_key`, so it survives
## leaving the room and saving. The scene only shows that state.

enum State {OFF, WOOD, LIT}

## AnimationPlayer animations (default library) for each state.
const ANIMATIONS := {
	State.OFF: &"off",
	State.WOOD: &"wood",
	State.LIT: &"lit",
}

## Item consumed when loading the grate. Must exist in data/items/.
@export var fuel_item: StringName = &"firewood"

## Where the state is stored. Give each fireplace in the game its own key.
@export var state_key: StringName = &"fireplace_living_room"

@onready var _animation_player: AnimationPlayer = $AnimationPlayer

var state: State = State.OFF:
	set(value):
		state = value
		GameState.props[state_key] = value
		if is_node_ready():
			_animation_player.play(ANIMATIONS[state])


func _ready() -> void:
	super()
	state = int(GameState.props.get(state_key, State.OFF)) as State
	_animation_player.play(ANIMATIONS[state])
	EventBus.day_started.connect(_on_day_started)


## A fire doesn't last the night.
func _on_day_started(_day: int) -> void:
	state = State.OFF


func can_interact(by: Node2D) -> bool:
	return super(by) and state != State.LIT


func get_prompt(_by: Node2D) -> String:
	match state:
		State.OFF:
			if Inventory.has(fuel_item):
				return "Add firewood"
			return "Needs firewood"
		State.WOOD:
			return "Light fire"
	return ""


func _on_interact(_by: Node2D) -> void:
	match state:
		State.OFF:
			if Inventory.remove(fuel_item):
				state = State.WOOD
		State.WOOD:
			state = State.LIT
