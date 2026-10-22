extends Camera2D

## Follows the player and clamps itself to the world so the camera never
## pans off into empty space. Bounds are derived from every TileMapLayer in
## the current scene, so the map can grow without touching this script.

@export var smoothing_speed := 8.0
@export var clamp_to_world := true
@export var padding_px := 0


func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = smoothing_speed
	if clamp_to_world:
		# Wait for the level to finish building before measuring it.
		call_deferred("fit_limits_to_world")


func fit_limits_to_world() -> void:
	var layers: Array[TileMapLayer] = []
	_collect_layers(get_tree().current_scene, layers)

	var bounds := Rect2()
	var found := false
	for layer in layers:
		if layer.tile_set == null:
			continue
		var used := layer.get_used_rect()
		if used.size == Vector2i.ZERO:
			continue
		var tile_size := Vector2(layer.tile_set.tile_size)
		var local := Rect2(Vector2(used.position) * tile_size, Vector2(used.size) * tile_size)
		var world: Rect2 = layer.get_global_transform() * local
		if found:
			bounds = bounds.merge(world)
		else:
			bounds = world
			found = true

	# Interiors have no tilemap. They mark their extent with a ReferenceRect
	# (or any Control) in the "camera_bounds" group instead.
	if not found:
		for node in get_tree().get_nodes_in_group(&"camera_bounds"):
			var ctrl := node as Control
			if ctrl == null:
				continue
			var r := ctrl.get_global_rect()
			bounds = r if not found else bounds.merge(r)
			found = true

	if not found:
		push_warning("PlayerCamera: no tile layers or camera_bounds found; limits left at default.")
		return

	bounds = bounds.grow(float(padding_px))

	# Always clamp to the measured world. Deliberately no "is the map bigger
	# than the screen?" test: at runtime neither get_viewport_rect() nor
	# ProjectSettings reports the game's logical 640x360 reliably (a headless
	# run sees 1820x600), and a wrong answer there silently disables clamping.
	# A room smaller than the view just pins the camera, which is harmless.
	limit_left = int(bounds.position.x)
	limit_right = int(bounds.position.x + bounds.size.x)
	limit_top = int(bounds.position.y)
	limit_bottom = int(bounds.position.y + bounds.size.y)

	reset_smoothing()


func _collect_layers(node: Node, out: Array[TileMapLayer]) -> void:
	if node == null:
		return
	if node is TileMapLayer:
		out.append(node)
	for child in node.get_children():
		_collect_layers(child, out)
