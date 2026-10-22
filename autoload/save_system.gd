extends Node

## Writes GameState to disk and reads it back (M3). The save is one Variant
## dictionary - GameState.to_dict() plus where the player is standing - stored
## with FileAccess.store_var, which keeps StringName keys and ints intact
## (JSON would turn them into Strings and floats).
##
## The game autosaves every morning, after the player sleeps. In debug builds
## F5 quicksaves and F9 quickloads.

const SAVE_PATH := "user://save.dat"
const TEMP_PATH := "user://save.dat.tmp"

signal saved()
signal loaded()

var _sleeping := false                 ## between day_ended and day_started


func _ready() -> void:
	EventBus.day_ended.connect(func(_day: int, _summary: Dictionary) -> void: _sleeping = true)
	EventBus.day_started.connect(_on_day_started)


func _on_day_started(_day: int) -> void:
	# GameClock also emits day_started at boot; only a real night counts.
	if _sleeping:
		_sleeping = false
		save_game()


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build() or not event is InputEventKey or not event.pressed or event.echo:
		return
	match (event as InputEventKey).physical_keycode:
		KEY_F5:
			save_game()
		KEY_F9:
			load_game()


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game() -> bool:
	var data := GameState.to_dict()
	var scene := get_tree().current_scene
	if scene != null:
		data["scene"] = scene.scene_file_path
	var player := SceneRouter.get_player()
	if player != null:
		data["position"] = player.global_position

	# Write a temp file first, then swap it in, so a crash mid-write
	# never leaves a half-written save behind.
	var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveSystem: can't write %s (%s)" % [TEMP_PATH, error_string(FileAccess.get_open_error())])
		return false
	file.store_var(data)
	file.close()
	var dir := DirAccess.open("user://")
	var err := dir.rename(TEMP_PATH.get_file(), SAVE_PATH.get_file())
	if err != OK:
		push_error("SaveSystem: can't replace %s (%s)" % [SAVE_PATH, error_string(err)])
		return false
	saved.emit()
	return true


## Restores the save and moves the player back to where they were.
func load_game() -> bool:
	var data := read_save()
	if data.is_empty():
		return false
	GameState.from_dict(data)
	var scene_path: String = data.get("scene", "")
	if scene_path != "" and ResourceLoader.exists(scene_path):
		await SceneRouter.travel(scene_path, &"")
	var player := SceneRouter.get_player()
	if player != null and data.has("position"):
		player.global_position = data["position"]
		var cam := player.get_node_or_null("Camera2D") as Camera2D
		if cam != null:
			cam.reset_smoothing()
	loaded.emit()
	return true


## The raw save dictionary, or {} if there isn't a readable one.
func read_save() -> Dictionary:
	if not has_save():
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveSystem: can't read %s (%s)" % [SAVE_PATH, error_string(FileAccess.get_open_error())])
		return {}
	# allow_objects stays false: a save file must never be able to run code.
	var data = file.get_var(false)
	if not data is Dictionary:
		push_error("SaveSystem: %s is not a save file." % SAVE_PATH)
		return {}
	return data


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
