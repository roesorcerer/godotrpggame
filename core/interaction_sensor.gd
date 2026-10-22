extends Area2D

## Sits on the player and picks which Interactable the E key is talking about.
## Nearest wins, but anything the player is actually facing gets a hefty
## discount - so standing between a door and a bin and looking at the door
## targets the door.

## How much closer a thing in front of you counts as, in pixels.
const FACING_BONUS := 14.0
## Anything more than this far off your facing direction isn't "in front".
const FACING_DOT_MIN := 0.25

var _current: Interactable = null
var _last_prompt := ""


func _ready() -> void:
	collision_layer = 0
	collision_mask = Interactable.LAYER
	monitoring = true
	monitorable = false


func _physics_process(_delta: float) -> void:
	var best := _pick_best()
	if best != _current:
		_current = best
	_push_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	if _current == null or GameClock.is_paused():
		return
	get_viewport().set_input_as_handled()
	_current.interact(owner)


func _pick_best() -> Interactable:
	var origin := global_position
	var face := _facing_vector()
	var best: Interactable = null
	var best_score := INF

	for area in get_overlapping_areas():
		var it := area as Interactable
		if it == null or not it.can_interact(owner):
			continue
		var to_it := it.global_position - origin
		var score := to_it.length()
		if face != Vector2.ZERO and to_it.length() > 0.001:
			if to_it.normalized().dot(face) >= FACING_DOT_MIN:
				score -= FACING_BONUS
		score -= float(it.interact_priority)
		if score < best_score:
			best_score = score
			best = it
	return best


func _facing_vector() -> Vector2:
	var f = owner.get("facing") if owner != null else null
	match f:
		"up": return Vector2.UP
		"down": return Vector2.DOWN
		"left": return Vector2.LEFT
		"right": return Vector2.RIGHT
	return Vector2.ZERO


func _push_prompt() -> void:
	var text := ""
	if _current != null and not GameClock.is_paused():
		text = _current.get_prompt(owner)
	if text != _last_prompt:
		_last_prompt = text
		EventBus.interaction_prompt.emit(text)


## Clear the prompt when the player is taken out of play (scene change, sleep).
func clear() -> void:
	_current = null
	if _last_prompt != "":
		_last_prompt = ""
		EventBus.interaction_prompt.emit("")
