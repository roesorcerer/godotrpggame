extends Node

## Dev-only smoke test for the openable crate: the player's sensor finds it and
## offers a prompt, opening it plays the lid animation, and it pays out its loot
## exactly once.
##   godot --headless --path . res://dev/crate_smoke.tscn

var _failures: Array[String] = []
var _finished := false            ## set by the last line of _run(); a script error skips it


func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await _run()
	if not _finished:
		_failures.append("_run() did not finish - see the script error above")
	if _failures.is_empty():
		print("CRATE SMOKE: PASS")
		get_tree().quit(0)
	else:
		for f in _failures:
			printerr("CRATE SMOKE FAIL: ", f)
		get_tree().quit(1)


func _check(cond: bool, label: String) -> void:
	if not cond:
		_failures.append(label)


func _run() -> void:
	var prompts: Array[String] = []
	EventBus.interaction_prompt.connect(func(t): prompts.append(t))

	# The HUD holds a pause through the day-start fade; wait it out so prompts
	# are live, exactly as they are when the real level has settled.
	var guard := 0
	while GameClock.is_paused() and guard < 600:
		await get_tree().process_frame
		guard += 1

	# The crate is placed right on top of the player so the sensor must see it.
	var player: Node2D = load("res://actors/player/player.tscn").instantiate()
	player.position = Vector2.ZERO
	add_child(player)
	var crate: Crate = load("res://props/crate/crate.tscn").instantiate()
	crate.position = Vector2.ZERO
	add_child(crate)
	for i in 4:
		await get_tree().physics_frame

	_check(crate.loot != null, "the crate has loot configured in its scene")
	_check(crate.can_interact(player), "a closed crate offers interaction")
	_check(crate.get_prompt(player) == "Open crate", "prompt is 'Open crate', got '%s'" % crate.get_prompt(player))
	_check(prompts.has("Open crate"), "the sensor pushed the crate prompt, got %s" % [prompts])

	var before := Inventory.count_of(crate.loot.id)
	crate.interact(player)
	await get_tree().physics_frame
	_check(crate.opened, "opening set the opened flag")
	_check(Inventory.count_of(crate.loot.id) == before + crate.loot_count,
			"opening paid out %d loot, got %d" % [crate.loot_count, Inventory.count_of(crate.loot.id) - before])
	_check(not crate.can_interact(player), "an open crate no longer offers interaction")

	# Interacting again must not pay out a second time.
	var after := Inventory.count_of(crate.loot.id)
	crate.interact(player)
	_check(Inventory.count_of(crate.loot.id) == after, "a second interact pays out nothing")

	_finished = true