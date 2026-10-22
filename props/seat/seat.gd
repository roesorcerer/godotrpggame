class_name Seat
extends Interactable

## Something the player can sit on: chairs, the couch, a stool. Press E to sit,
## E again (or any movement key) to stand. What sitting looks like comes from
## the first available SeatActivity, so one chair can mean breakfast in the
## morning and homework in the afternoon.

## Which way the seated player faces on the chair's own art; picks
## "<animation>_<facing>". Mirror the chair in a scene (scale.x = -1, or the
## rotation + scale.y flip) and this flips with it - see is_mirrored().
@export_enum("right", "left") var facing := "right"

## Where the player's feet go, relative to the seat's parent (the chair).
## Keep y just below the chair's origin so the player draws over the seat.
@export var sit_offset := Vector2(1, 1)

## Sprite position while seated (sit frames are 16x32 and need lifting onto
## the seat instead of standing on the floor).
@export var sprite_offset := Vector2(-1, -25)

## Checked in order; the first available one is used. Empty = plain "Sit".
@export var activities: Array[SeatActivity] = []

var occupant: Node2D = null


func can_interact(by: Node2D) -> bool:
	if occupant != null:
		return occupant == by
	return super(by) and by.get("can_move") == true


func get_prompt(by: Node2D) -> String:
	if occupant == by:
		return "Stand up"
	var activity := current_activity()
	return activity.prompt if activity != null else "Sit"


func _on_interact(by: Node2D) -> void:
	if occupant == by:
		by.stand_up()
		return
	var activity := current_activity()
	var animation: StringName = activity.animation if activity != null else &"sit"
	occupant = by
	by.sit(self, StringName("%s_%s" % [animation, seated_facing()]))
	if activity != null:
		_apply(activity)


## Do what the activity does: restore Gas, pass the time, mark it done for the
## day, and say its line if it has one.
func _apply(activity: SeatActivity) -> void:
	if activity.restore_gas > 0:
		GameState.restore_gas(activity.restore_gas)
	if activity.minutes > 0:
		GameClock.advance(activity.minutes)
	if activity.id != &"":
		GameState.meals_today.append(String(activity.id))
	if activity.line != "":
		EventBus.npc_said.emit("You", activity.line, null)


func current_activity() -> SeatActivity:
	for activity in activities:
		if activity.is_available():
			return activity
	return null


## True when the chair has been flipped left-right in the scene, however it
## was done: its X axis then points left in world space.
func is_mirrored() -> bool:
	return get_parent().global_transform.x.x < 0.0


## `facing` after accounting for a mirrored chair.
func seated_facing() -> String:
	if not is_mirrored():
		return facing
	return "left" if facing == "right" else "right"


func _mirror_x(v: Vector2) -> Vector2:
	return Vector2(-v.x, v.y) if is_mirrored() else v


func sit_position() -> Vector2:
	return get_parent().global_position + _mirror_x(sit_offset)


## Player sprite position while seated, mirrored with the chair.
func seated_sprite_offset() -> Vector2:
	return _mirror_x(sprite_offset)


## Called by the player when they get up, however they got up.
func release() -> void:
	occupant = null
