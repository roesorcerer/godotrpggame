extends Node

## Dev-only check that every scene and resource in the project still loads and
## every scene instantiates - run it after moving or renaming files.
##   godot --headless --path . res://dev/load_all_smoke.tscn

const SKIP_DIRS := ["res://addons", "res://.godot", "res://art_library"]

var _failures: Array[String] = []
var _loaded := 0


func _ready() -> void:
	await get_tree().process_frame
	_walk("res://")
	if _failures.is_empty():
		print("LOAD-ALL SMOKE: PASS (%d files)" % _loaded)
		get_tree().quit(0)
	else:
		for f in _failures:
			printerr("LOAD-ALL SMOKE FAIL: ", f)
		get_tree().quit(1)


func _walk(dir_path: String) -> void:
	if SKIP_DIRS.has(dir_path.trim_suffix("/")):
		return
	var dir := DirAccess.open(dir_path)
	if dir == null:
		_failures.append("can't open %s" % dir_path)
		return
	for sub in dir.get_directories():
		_walk(dir_path.path_join(sub))
	for file in dir.get_files():
		var path := dir_path.path_join(file.trim_suffix(".remap"))
		if path.ends_with(".tscn") or path.ends_with(".tres"):
			_check(path)


func _check(path: String) -> void:
	_loaded += 1
	var res := ResourceLoader.load(path)
	if res == null:
		_failures.append("%s doesn't load" % path)
		return
	# Instantiating catches broken sub-scenes and scripts that won't attach.
	# Smoke-test scenes are skipped: they run themselves on _ready.
	if res is PackedScene and not path.begins_with("res://dev/"):
		var node := (res as PackedScene).instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		if node == null:
			_failures.append("%s doesn't instantiate" % path)
		else:
			node.free()
