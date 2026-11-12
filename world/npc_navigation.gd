class_name NpcNavigation
extends NavigationRegion2D

## Walkable area for NPCs, baked when the scene loads: everything inside the
## map's bounds, minus every static collider (walls, fences, buildings,
## furniture, the Collision tile layer). Drop one at the root of a scene,
## position (0, 0), and NPCs there path around obstacles instead of walking
## into them.
##
## Bounds come from the TileMapLayers, or from the "camera_bounds" ReferenceRect
## in interiors - the same rule the player camera uses. Set `bounds` to
## override.

## How far NPCs keep from walls; about half their body width.
@export var agent_radius := 6.0

## Empty = measure the map.
@export var bounds := Rect2()

signal baked


func _ready() -> void:
	# Wait for the rest of the scene so its colliders exist to be parsed.
	await get_tree().process_frame
	bake_now()


func bake_now() -> void:
	var r := bounds if bounds.has_area() else _measure_world()
	if not r.has_area():
		push_warning("NpcNavigation: no bounds to bake in.")
		return
	r = Rect2(to_local(r.position), r.size)

	var poly := NavigationPolygon.new()
	poly.agent_radius = agent_radius
	poly.parsed_geometry_type = NavigationPolygon.PARSED_GEOMETRY_STATIC_COLLIDERS
	poly.add_outline(PackedVector2Array([
		r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]))

	var source := NavigationMeshSourceGeometryData2D.new()
	var root := owner if owner != null else get_parent()
	NavigationServer2D.parse_source_geometry_data(poly, source, root)
	NavigationServer2D.bake_from_source_geometry_data(poly, source)
	navigation_polygon = poly
	baked.emit()


func _measure_world() -> Rect2:
	var root := owner if owner != null else get_parent()
	var found := false
	var out := Rect2()
	for node in root.find_children("*", "TileMapLayer", true, false):
		var layer := node as TileMapLayer
		if layer.tile_set == null or layer.get_used_rect().size == Vector2i.ZERO:
			continue
		var used := layer.get_used_rect()
		var size := Vector2(layer.tile_set.tile_size)
		var world: Rect2 = layer.get_global_transform() * Rect2(Vector2(used.position) * size, Vector2(used.size) * size)
		out = world if not found else out.merge(world)
		found = true
	# Interiors: the camera_bounds rect is the house, the tile layers spill past it.
	for node in get_tree().get_nodes_in_group(&"camera_bounds"):
		if node is Control and root.is_ancestor_of(node):
			return (node as Control).get_global_rect()
	return out
