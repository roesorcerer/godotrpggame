class_name ChoreSpot
extends Interactable

## A place where a chore gets done: the sink, the ashtrays, the hamper. Usually
## pinned to one chore; it offers it only while that chore is on today's list
## and not yet done, then goes quiet until it comes round again.

## Leave blank to take the room from the RoomZone this spot is under.
@export var room: StringName = &""

## The chore this spot does. Leave empty to offer whatever this room still
## needs today.
@export var only_chore: StringName = &""

var _offer: ChoreData = null
var _room_id: StringName = &""


func _ready() -> void:
	super()
	_room_id = RoomZone.resolve(self, room)
	if only_chore != &"" and ChoreSystem.get_chore(only_chore) == null:
		push_warning("%s pins '%s', which is not a chore in data/chores/." % [get_path(), only_chore])
	EventBus.chores_changed.connect(_refresh)
	EventBus.gas_changed.connect(func(_c, _m): _refresh())
	_refresh()


func _refresh() -> void:
	_offer = _pick()


func _pick() -> ChoreData:
	if only_chore != &"":
		var pinned := ChoreSystem.get_chore(only_chore)
		return pinned if pinned != null and ChoreSystem.is_needed(pinned) else null
	var options := ChoreSystem.available_in_room(_room_id)
	return options[0] if not options.is_empty() else null


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
