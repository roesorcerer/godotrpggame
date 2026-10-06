class_name RoomZone
extends Area2D

## One room of the house, and the parent of everything in it:
##
##   World/RoomZones/Kitchen      (this node)
##     Rect                       CollisionShape2D - the floor footprint
##     Sink, Fridge, MailPile...  chore spots, mess props, furniture
##
## Only DIRECT CollisionShape2D children count as the room's footprint (an
## L-shaped room is two rectangles; the halls are three). A piece of
## furniture's own collision belongs inside that piece, not here.
##
## Two jobs:
##   - Tells the HUD which room the player is standing in.
##   - ChoreSpots with `room` left blank take it from the room they are
##     parented under (or, outside any room, the rectangle they sit in).

const GROUP := &"room_zones"

## Matches ChoreData.room for the chores done in here.
@export var room_id: StringName = &""

## Shown in the HUD. Blank = made from room_id ("living_room" -> "Living Room").
@export var display_name := ""


func _enter_tree() -> void:
	# Before any _ready, so props resolving their room always find us.
	add_to_group(GROUP)
	# The room's furniture and props must sort against the player one by one,
	# not as a single block. (RoomZones above us needs y-sort on as well.)
	y_sort_enabled = true


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1          ## the player's body (default layer 1)
	monitorable = false
	body_entered.connect(_on_body_entered)
	if room_id == &"":
		push_warning("RoomZone %s has no room_id." % name)


func get_display_name() -> String:
	return display_name if display_name != "" else String(room_id).capitalize()


## Display name for a room id, from whichever zone in the scene carries it.
static func name_of(tree: SceneTree, id: StringName) -> String:
	for zone in tree.get_nodes_in_group(GROUP):
		if (zone as RoomZone).room_id == id:
			return (zone as RoomZone).get_display_name()
	return String(id).capitalize()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(SceneRouter.PLAYER_GROUP):
		EventBus.room_entered.emit(room_id)


## True when the world-space point falls inside any of this zone's rectangles.
func contains(point: Vector2) -> bool:
	for child in get_children():
		var shape_node := child as CollisionShape2D
		if shape_node == null or shape_node.disabled:
			continue
		var rect_shape := shape_node.shape as RectangleShape2D
		if rect_shape == null:
			continue
		var local := shape_node.global_transform.affine_inverse() * point
		if Rect2(-rect_shape.size / 2.0, rect_shape.size).has_point(local):
			return true
	return false


## The room at a world position, or &"" when it's in no zone.
static func room_at(tree: SceneTree, point: Vector2) -> StringName:
	for zone in tree.get_nodes_in_group(GROUP):
		if (zone as RoomZone).contains(point):
			return (zone as RoomZone).room_id
	return &""


## The RoomZone this node is parented under, or null.
static func owning_zone(node: Node) -> RoomZone:
	var n := node.get_parent()
	while n != null:
		if n is RoomZone:
			return n
		n = n.get_parent()
	return null


## For props: the explicit room if one is set, else the room it is parented
## under, else the rectangle it sits in. Warns when they disagree - a prop
## parented to the kitchen but dragged into the dining room, say.
static func resolve(node: Node2D, explicit_room: StringName) -> StringName:
	var parent_zone := owning_zone(node)
	var zoned := room_at(node.get_tree(), node.global_position)
	if parent_zone != null:
		if zoned != &"" and zoned != parent_zone.room_id:
			push_warning("%s is under %s but sits inside the '%s' rectangle." % [
				node.get_path(), parent_zone.name, zoned])
		if explicit_room != &"" and explicit_room != parent_zone.room_id:
			push_warning("%s is set to '%s' but is under %s." % [node.get_path(), explicit_room, parent_zone.name])
			return explicit_room
		return parent_zone.room_id
	if explicit_room == &"":
		if zoned == &"":
			push_warning("%s is in no RoomZone and has no room set." % node.get_path())
		return zoned
	if zoned != &"" and zoned != explicit_room:
		push_warning("%s is set to '%s' but sits in the '%s' zone." % [node.get_path(), explicit_room, zoned])
	return explicit_room
