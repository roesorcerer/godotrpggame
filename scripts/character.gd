extends CharacterBody2D

@export var speed := 80.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var facing := "down"


func _ready() -> void:
	add_to_group("player")

func _physics_process(_delta: float) -> void:
	# No walking during a fade, a cutscene or a menu.
	if GameClock.is_paused():
		velocity = Vector2.ZERO
		move_and_slide()
		sprite.play("idle_" + facing)
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	_update_animation(direction)

func _update_animation(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			facing = "right" if direction.x > 0 else "left"
		else:
			facing = "down" if direction.y > 0 else "up"
		sprite.play("walk_" + facing)
	else:
		sprite.play("idle_" + facing)
