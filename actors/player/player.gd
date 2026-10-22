extends CharacterBody2D

var speed := 50
var direction : Vector2
var can_move: bool = true
var last_direction :Vector2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var move_state_machine = $Animation/AnimationTree.get("parameters/MoveStateMachine/playback")
@onready var tool_state_machine = $Animation/AnimationTree.get("parameters/ToolStateMachine/playback")

signal tool_use(tool: Enum.Tool, pos: Vector2, seed_type: Enum.Seed)

## Follows the held hotbar item (see _sync_tool); false = not holding a tool.
var current_tool : Enum.Tool = Enum.Tool.SHOVEL
var holding_tool := false
var current_seed: Enum.Seed
var _swing_tool: Enum.Tool              ## the tool the running swing started with

var seat: Seat = null
var _stand_position: Vector2

## Read by the InteractionSensor to prefer things in front of the player.
var facing: String:
	get:
		if absf(last_direction.x) > absf(last_direction.y):
			return "right" if last_direction.x > 0 else "left"
		return "up" if last_direction.y < 0 else "down"


# The tree is left inactive in the scene so it doesn't override animations
# while editing them; it only drives the sprite while the game runs.
func _ready() -> void:
	$Animation/AnimationTree.active = true
	EventBus.hotbar_selected.connect(func(_i): _sync_tool())
	EventBus.inventory_changed.connect(_sync_tool)
	_sync_tool()

func _physics_process(_delta: float) -> void:
	# Menus, the backpack and scene fades stop the clock; the player waits too.
	if GameClock.is_paused():
		return
	if seat:
		if Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO:
			stand_up()
		return
	if can_move:
		get_basic_input()
		move()
		animate()
		
	if direction:
		last_direction = direction


func get_basic_input():
	if Input.is_action_just_pressed("tool_forward") or Input.is_action_just_pressed("tool_backward"):
		var dir = Input.get_axis("tool_backward", "tool_forward")
		_cycle_tool(int(dir))

	if Input.is_action_just_pressed("seed_forward"):
		current_seed = posmod(current_seed + 1, Enum.Seed.size()) as Enum.Seed

	if Input.is_action_just_pressed("action") and holding_tool:
		_swing_tool = current_tool
		tool_state_machine.start(Data.TOOL_STATE_ANIMATIONS[current_tool])
		$Animation/AnimationTree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func move():
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()


	
func animate():
	if direction:
		move_state_machine.travel("Walk")
		var direction_animation = Vector2(round(direction.x),round(direction.y))
		$Animation/AnimationTree.set("parameters/MoveStateMachine/Walk/blend_position", direction_animation)
		$Animation/AnimationTree.set("parameters/MoveStateMachine/Idle/blend_position", direction_animation)
		for animation in Data.TOOL_STATE_ANIMATIONS.values():
			var animation_name: String = 'parameters/ToolStateMachine/'+ animation + "/blend_position"
			$Animation/AnimationTree.set(animation_name, direction_animation)
	else:
		move_state_machine.travel("Idle")


# Seated animations play straight on the sprite (any SpriteFrames animation,
# no AnimationTree setup needed), so the tree is paused until the player stands.
func sit(new_seat: Seat, animation: StringName) -> void:
	seat = new_seat
	can_move = false
	velocity = Vector2.ZERO
	direction = Vector2.ZERO
	_stand_position = global_position
	global_position = seat.sit_position()
	$Animation/AnimationTree.active = false
	sprite.position = seat.seated_sprite_offset()
	sprite.play(animation)


func stand_up() -> void:
	seat.release()
	seat = null
	global_position = _stand_position
	sprite.stop()
	$Animation/AnimationTree.active = true
	can_move = true


## Tools are hotbar items now: the held one is the current tool.
func _sync_tool() -> void:
	var item := Inventory.selected_item()
	holding_tool = item != null and item.category == Enum.ItemCategory.TOOL
	if holding_tool:
		current_tool = item.tool


## Keys 1/2 step to the next/previous hotbar slot holding a tool, wrapping.
func _cycle_tool(dir: int) -> void:
	if dir == 0:
		return
	for step in range(1, Data.HOTBAR_SIZE + 1):
		var index := posmod(Inventory.selected + dir * step, Data.HOTBAR_SIZE)
		var item := Inventory.item_at(index)
		if item != null and item.category == Enum.ItemCategory.TOOL:
			Inventory.select(index)
			return


# Uses the tool the swing started with, in case the hotbar changes mid-swing.
func tool_use_emit():
	tool_use.emit(_swing_tool, global_position + last_direction * 16 + Vector2(0,4), current_seed)


func _on_animation_tree_animation_started(_anim_name: StringName) -> void:
	can_move = false


func _on_animation_tree_animation_finished(_anim_name: StringName) -> void:
	can_move = true
