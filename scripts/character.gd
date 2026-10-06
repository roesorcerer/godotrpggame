extends CharacterBody2D

var speed := 50
var direction : Vector2
var can_move: bool = true

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var move_state_machine = $Animation/AnimationTree.get("parameters/MoveStateMachine/playback")

var current_tool : Enum.Tool
var current_seed: Enum.Seed 



func _physics_process(_delta: float) -> void:
	if can_move:
		get_basic_input()
		move()
		animate()
	

func get_basic_input():
	if Input.is_action_just_pressed("tool_forward") or Input.is_action_just_pressed("tool_backward"):
		var dir = Input.get_axis("tool_backward", "tool_forward")
		current_tool = posmod(current_tool + int(dir), Enum.Tool.size()) as Enum.Tool
	
	if Input.is_action_just_pressed("seed_forward"):
		current_seed =  posmod(current_seed + 1, Enum.Tool.size()) as Enum.Seed
	
	if Input.is_action_just_pressed("action"):
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
		$Animation/AnimationTree.set("parameters/MoveStateMachine/Walk/blend_position", direction_animation)
		for animation in Data.TOOL_STATE_ANIMATIONS.values():
			var animation_name: String = 'parameters/ToolStateMachine/'+ animation + "/blend_position"
			$Animation/AnimationTree.set(animation_name, direction_animation)
	else:
		move_state_machine.travel("Idle")
