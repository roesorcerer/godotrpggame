class_name Seat
extends Interactable

## Something the player can sit on: chairs, the couch, a stool. E sits down
## and opens a menu of what you can do here: a scheduled SeatActivity (Mom's
## breakfast), eat food from your backpack, or just sit. E again reopens the
## menu; any movement key stands you up.
## Eating happens sitting down, so the couch and the kitchen table are where
## meals are. A seat Mom sleeps on (the couch) is hers while she's out.

## Which way the seated player faces on the chair's own art; picks
## "<animation>_<facing>" (see seated_animation() for what happens when that
## doesn't exist). Mirror the chair in a scene (scale.x = -1, or the
## rotation + scale.y flip) and left/right flip with it - see is_mirrored().
## "forward" faces the camera, like on the couch.
@export_enum("right", "left", "forward") var facing := "right"

## Where the player's feet go, relative to the seat's parent (the chair).
## Keep y just below the chair's origin so the player draws over the seat.
@export var sit_offset := Vector2(1, 1)

## Sprite position while seated (sit frames are 16x32 and need lifting onto
## the seat instead of standing on the floor).
@export var sprite_offset := Vector2(-1, -25)

## Scheduled things this seat offers (Mom's breakfast and dinner). Each one
## that's available right now is an option in the menu; the first one also
## names the prompt ("Eat breakfast"). Empty = plain "Sit".
@export var activities: Array[SeatActivity] = []

## Food from the backpack can be eaten here.
@export var allows_eating := true

## Mom sleeps here (the couch): while she's asleep it's hers, and the player
## can't sit down.
@export var mom_sleeps_here := false

## Heading of the menu that opens when you sit.
@export var menu_title := "Sitting down"

## In-game minutes a meal from the backpack takes.
const EAT_MINUTES := 15

const MENU_SCENE := preload("res://ui/choice_menu/choice_menu.tscn")

var occupant: Node2D = null


func can_interact(by: Node2D) -> bool:
	if occupant != null:
		return occupant == by
	return super(by) and by.get("can_move") == true


func get_prompt(by: Node2D) -> String:
	if occupant == by:
		return "What now?"
	if is_taken_by_mom():
		return "Mom's asleep here"
	var activity := current_activity()
	return activity.prompt if activity != null else "Sit"


func _on_interact(by: Node2D) -> void:
	if occupant != by:
		if is_taken_by_mom():
			EventBus.notice.emit("She's out cold, one arm hanging off the cushion. You leave her be.")
			return
		var activity := current_activity()
		occupant = by
		by.sit(self, seated_animation(by, activity.animation if activity != null else &"sit"))
	open_menu(by)


## Mom's sleeping on it, so it isn't free.
func is_taken_by_mom() -> bool:
	return mom_sleeps_here and Mom.is_asleep()


## What the player can do from this seat right now, as ChoiceMenu options.
func options(by: Node2D) -> Array:
	var list := []
	for activity in activities:
		if activity.is_available() and _does_something(activity):
			list.append({"text": activity.prompt, "hint": activity.summary(),
					"action": _apply.bind(activity, by)})

	if allows_eating:
		var hungry := GameState.gas < GameState.gas_max
		for item in _foods_in_backpack():
			list.append({
				"text": "Eat %s" % item.display_name.to_lower(),
				"hint": ("+%d Gas, %d min" % [item.gas, EAT_MINUTES]) if hungry else "You're not hungry.",
				"disabled": not hungry,
				"action": _eat.bind(item),
			})

	list.append({"text": "Stand up", "action": func() -> void:
		if occupant == by:
			by.stand_up()})
	return list


func open_menu(by: Node2D) -> void:
	var menu: ChoiceMenu = MENU_SCENE.instantiate()
	get_tree().root.add_child(menu)
	menu.open(menu_title, options(by), "Just sit")


## Plain "Sit" is what "Just sit" already does; only list activities with an effect.
func _does_something(activity: SeatActivity) -> bool:
	return activity.id != &"" or activity.restore_gas > 0 or activity.minutes > 0


## Edible things in the backpack, one entry each, alphabetical.
func _foods_in_backpack() -> Array[ItemData]:
	var foods: Array[ItemData] = []
	for i in Inventory.size():
		var item := Inventory.item_at(i)
		if item != null and item.is_edible() and not foods.has(item):
			foods.append(item)
	foods.sort_custom(func(a: ItemData, b: ItemData) -> bool: return a.display_name < b.display_name)
	return foods


func _eat(item: ItemData) -> void:
	if Cooking.eat(item.id):
		GameClock.advance(EAT_MINUTES)


## Do what the activity does: take its pose, restore Gas, mark it done for
## the day, say its line, and pass the time.
func _apply(activity: SeatActivity, by: Node2D = null) -> void:
	if by != null and by.has_method("play_seated"):
		by.play_seated(seated_animation(by, activity.animation))
	if activity.restore_gas > 0:
		GameState.restore_gas(activity.restore_gas)
	if activity.id != &"":
		GameState.meals_today.append(String(activity.id))
	if activity.line != "":
		EventBus.notice.emit(activity.line)
	# Last: running the clock out ends the day.
	if activity.minutes > 0:
		GameClock.advance(activity.minutes)


## The player animation for `base` on this seat: "<base>_<facing>" if the
## player has it, else "<base>" on its own ("reading"), else the right-facing
## version (a forward seat with only side poses).
func seated_animation(by: Node2D, base: StringName) -> StringName:
	var with_facing := StringName("%s_%s" % [base, seated_facing()])
	var sprite := by.get("sprite") as AnimatedSprite2D if by != null else null
	if sprite == null or sprite.sprite_frames == null:
		return with_facing
	for p_name in [with_facing, base, StringName("%s_right" % base)]:
		if sprite.sprite_frames.has_animation(p_name):
			return p_name
	return with_facing


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
	if not is_mirrored() or facing == "forward":
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
