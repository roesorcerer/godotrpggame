extends Node

## Moves the player between scenes: fade out, swap, drop them on the named
## spawn marker, fade in. Each scene carries its own player instance, so this
## only has to place it and re-aim the camera.

const PLAYER_GROUP := &"player"

var _travelling := false


func is_travelling() -> bool:
	return _travelling


## spawn_name is the exact node name of a Marker2D in the destination scene.
func travel(scene_path: String, spawn_name: StringName) -> void:
	if _travelling:
		return
	if not ResourceLoader.exists(scene_path):
		push_error("SceneRouter: no scene at %s" % scene_path)
		return

	_travelling = true
	GameClock.request_pause()
	_clear_player_prompt()

	await HUD.fade_to_black()

	var err := get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("SceneRouter: change_scene_to_file failed (%d) for %s" % [err, scene_path])
		await HUD.fade_from_black()
		GameClock.release_pause()
		_travelling = false
		return

	# current_scene is only valid after the tree swaps it in.
	await get_tree().process_frame
	await get_tree().process_frame

	# Forget the old room; a RoomZone at the spawn point will re-announce.
	EventBus.room_entered.emit(&"")
	_place_player(spawn_name)

	await HUD.fade_from_black()
	GameClock.release_pause()
	_travelling = false


func get_player() -> Node2D:
	return get_tree().get_first_node_in_group(PLAYER_GROUP) as Node2D


func _place_player(spawn_name: StringName) -> void:
	var player := get_player()
	if player == null:
		push_warning("SceneRouter: destination scene has no node in group '%s'." % PLAYER_GROUP)
		return

	if spawn_name != &"":
		var marker := get_tree().current_scene.find_child(String(spawn_name), true, false)
		if marker is Node2D:
			player.global_position = (marker as Node2D).global_position
		else:
			push_warning("SceneRouter: spawn marker '%s' not found." % spawn_name)

	# Re-measure the new map and snap the camera instead of gliding to it.
	var cam := player.get_node_or_null("Camera2D") as Camera2D
	if cam != null:
		if cam.has_method("fit_limits_to_world"):
			cam.call("fit_limits_to_world")
		cam.reset_smoothing()


func _clear_player_prompt() -> void:
	var player := get_player()
	if player == null:
		return
	var sensor := player.get_node_or_null("InteractionSensor")
	if sensor != null and sensor.has_method("clear"):
		sensor.call("clear")
