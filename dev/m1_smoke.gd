extends Node

## Dev-only smoke test for the M1 interaction layer: sensor targeting, the
## door, the scene swap, the spawn marker, the stairs, and the bed upstairs
## ending the day.
##   godot --headless --path . res://dev/m1_smoke.tscn

var _failures: Array[String] = []
var _finished := false            ## set by the last line of _run(); a script error skips it
var _prompts: Array[String] = []


func _ready() -> void:
	# change_scene_to_file() frees the current scene - which would take this
	# node and its running coroutine with it. Move under the root first.
	call_deferred("_boot")


func _boot() -> void:
	var root := get_tree().root      # grab this BEFORE detaching, or get_tree() is null
	get_parent().remove_child(self)
	root.add_child(self)

	EventBus.interaction_prompt.connect(func(t): _prompts.append(t))
	get_tree().change_scene_to_file("res://world/ranch/ranch.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	await _run()
	if not _finished:
		_failures.append("_run() did not finish - see the script error above")
	if _failures.is_empty():
		print("M1 SMOKE: PASS")
		get_tree().quit(0)
	else:
		for f in _failures:
			printerr("M1 SMOKE FAIL: ", f)
		get_tree().quit(1)


func _check(cond: bool, label: String) -> void:
	if not cond:
		_failures.append(label)


func _settle(frames := 4) -> void:
	for i in frames:
		await get_tree().process_frame


func _await_travel() -> void:
	var guard := 0
	while SceneRouter.is_travelling() and guard < 2000:
		guard += 1
		await get_tree().process_frame
	_check(guard < 2000, "travel finished within time")


func _run() -> void:
	var player := SceneRouter.get_player()
	_check(player != null, "player is findable via the 'player' group")
	if player == null:
		return

	# Found by script, not name: the sensor node has been renamed before.
	var sensor: Node = null
	for child in player.get_children():
		if child.get_script() == preload("res://core/interaction_sensor.gd"):
			sensor = child
	_check(sensor != null, "player has an interaction sensor")

	var door := get_tree().current_scene.find_child("FrontDoor", true, false) as Door
	_check(door != null, "ranch.tscn has a FrontDoor")
	if door == null or sensor == null:
		return
	_check(door.target_scene == "res://world/ranch_interior/ranch_interior.tscn", "door points at the interior")

	# The morning fade holds a clock pause; prompts are suppressed until it ends.
	var guard := 0
	while GameClock.is_paused() and guard < 3000:
		guard += 1
		await get_tree().process_frame
	_check(not GameClock.is_paused(), "morning fade released the clock")

	# --- standing away from the door: no prompt ---
	player.global_position = door.global_position + Vector2(300, 300)
	await _settle(4)
	_check(sensor.get("_current") == null, "nothing targeted when far away")

	# --- standing at the door: it gets targeted and prompts ---
	_prompts.clear()
	player.global_position = door.global_position + Vector2(0, 18)
	player.set("facing", "up")
	await _settle(8)
	_check(sensor.get("_current") == door, "door is targeted when stood on")
	_check(_prompts.has("Go inside"), "prompt fired, got %s" % [_prompts])

	# --- through the door ---
	var before_day := GameClock.day
	door.interact(player)
	await _await_travel()
	await _settle(2)

	var scene := get_tree().current_scene
	_check(scene != null and scene.name == "RanchInterior", "we are inside, got %s" % [scene.name if scene else "<null>"])

	var inside_player := SceneRouter.get_player()
	_check(inside_player != null, "interior has its own player")
	var spawn := scene.find_child("Spawn_Interior", true, false) as Node2D
	_check(spawn != null, "interior has Spawn_Interior")
	if inside_player != null and spawn != null:
		_check(inside_player.global_position.distance_to(spawn.global_position) < 1.0,
			"player landed on the spawn marker, at %s vs %s" % [inside_player.global_position, spawn.global_position])

	# --- camera picked up the interior bounds (no tilemap in here) ---
	var cam := inside_player.get_node_or_null("Camera2D") as Camera2D
	_check(cam != null and cam.limit_right > 0 and cam.limit_right < 100000,
		"camera clamped to the room, limit_right=%d" % [cam.limit_right if cam else -1])

	# --- up the stairs to the second floor ---
	var stairs := scene.find_child("Stairs", true, false) as Stairs
	_check(stairs != null, "interior has Stairs")
	if stairs == null:
		return
	_check(stairs.target_scene == "res://world/ranch_interior/secondfloor/ranch_second_floor_interior.tscn",
		"stairs point at the second floor, got %s" % stairs.target_scene)
	stairs.interact(inside_player)
	await _await_travel()
	await _settle(2)
	scene = get_tree().current_scene
	_check(scene != null and scene.name == "RanchSecondFloorInterior", "we are upstairs")
	var up_player := SceneRouter.get_player()
	var up_spawn := scene.find_child("Spawn_Upstairs", true, false) as Node2D
	_check(up_player != null and up_spawn != null
		and up_player.global_position.distance_to(up_spawn.global_position) < 1.0,
		"player landed on Spawn_Upstairs")
	_check(Mom._player_in_house(), "upstairs still counts as in the house (family dinner)")
	var down := scene.find_child("StairsDown", true, false) as Stairs
	_check(down != null and down.target_scene == "res://world/ranch_interior/ranch_interior.tscn"
		and down.target_spawn == &"Spawn_Downstairs", "StairsDown leads back to Spawn_Downstairs")

	# --- the bed in your room ends the day ---
	var bed := scene.find_child("Bed", true, false) as Bed
	_check(bed != null, "the second floor has the Bed")
	if bed == null or up_player == null:
		return
	GameClock.minutes = (bed.too_early_hour - GameClock.START_HOUR) * 60 - 1    # 7:59 PM
	_check(bed.get_prompt(up_player) == "Too early to sleep", "bed refuses at 7:59 PM")
	GameClock.minutes += 1                                                        # 8:00 PM
	_check(bed.get_prompt(up_player) == "Go to sleep", "bed prompts at 8 PM")
	bed.interact(up_player)
	await _settle(2)
	_check(GameClock.day == before_day + 1, "bed advanced the day")

	# --- and it is too early to sleep at 7 AM ---
	GameClock.minutes = 0
	_check(bed.get_prompt(up_player) == "Too early to sleep", "bed refuses at 7 AM")

	# --- and back down ---
	down.interact(up_player)
	await _await_travel()
	await _settle(2)
	scene = get_tree().current_scene
	_check(scene != null and scene.name == "RanchInterior", "the stairs lead back down")
	var down_spawn := scene.find_child("Spawn_Downstairs", true, false) as Node2D
	var back_player := SceneRouter.get_player()
	_check(down_spawn != null and back_player != null
		and back_player.global_position.distance_to(down_spawn.global_position) < 1.0,
		"player landed on Spawn_Downstairs")
	_finished = true
