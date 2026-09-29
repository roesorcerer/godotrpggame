class_name ChoreSpot
extends Interactable

## A place in a room where work is waiting: the sink, the ashtrays, the stack of
## boxes. Bound to one room; it offers whichever chore in that room still needs
## doing, so one node covers the whole life of the spot.

@export var room: StringName = &"living_room"

## Leave empty to offer whatever this room needs. Set it to pin one chore.
@export var only_chore: StringName = &""

var _offer: ChoreData = null


func _ready() -> void:
	super()
	EventBus.room_state_changed.connect(_on_room_changed)
	EventBus.gas_changed.connect(func(_c, _m): _refresh())
	_refresh()


func _on_room_changed(room_id: StringName) -> void:
	if room_id == room:
		_refresh()


func _refresh() -> void:
	_offer = _pick()


func _pick() -> ChoreData:
	if only_chore != &"":
		var pinned := ChoreSystem.get_chore(only_chore)
		return pinned if pinned != null and ChoreSystem.is_needed(pinned) else null
	var options := ChoreSystem.available_in_room(room)
	if options.is_empty():
		return null
	# Grime first - the daily rhythm should feel like the default.
	options.sort_custom(func(a, b): return a.kind < b.kind)
	return options[0]


func can_interact(by: Node2D) -> bool:
	_refresh()
	return super(by) and _offer != null


func get_prompt(_by: Node2D) -> String:
	if _offer == null:
		return ""
	var blocked := ChoreSystem.blocked_reason(_offer)
	if blocked != "":
		return "%s (%s)" % [_offer.display_name, blocked]
	return "%s  -%d gas, %dm" % [_offer.display_name, _offer.gas_cost, _offer.minutes]


func _on_interact(_by: Node2D) -> void:
	if _offer == null:
		return
	ChoreSystem.perform(_offer)
	_refresh()
