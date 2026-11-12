extends Node

## Dev-only smoke test for NPC schedules (Bruce): fence at 7, walks off to the
## barn at 9, walks in from the front door and sits on the couch at 1 PM,
## heads upstairs at 8 PM and is by his bed on the second floor.
##   godot --headless --path . res://dev/npc_schedule_smoke.tscn

const RANCH := "res://world/ranch/ranch.tscn"
const INTERIOR := "res://world/ranch_interior/ranch_interior.tscn"
const UPSTAIRS := "res://world/ranch_interior/secondfloor/ranch_second_floor_interior.tscn"

var _failures: Array[String] = []
var _finished := false


func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await _run()
	if not _finished:
		_failures.append("_run() did not finish - see the script error above")
	if _failures.is_empty():
		print("NPC SCHEDULE SMOKE: PASS")
		get_tree().quit(0)
	else:
		for f in _failures:
			printerr("NPC SCHEDULE SMOKE FAIL: ", f)
		get_tree().quit(1)


func _check(cond: bool, label: String) -> void:
	if not cond:
		_failures.append(label)


func _set_hour(h: int) -> void:
	GameClock.minutes = (h - GameClock.START_HOUR) * 60


func _load(path: String) -> Node:
	var scene: Node = load(path).instantiate()
	get_tree().root.add_child(scene)
	for i in 4:
		await get_tree().process_frame     # NpcNavigation bakes after one
	return scene


func _bruce(scene: Node) -> Npc:
	return _npc(scene, "Bruce")


func _mom(scene: Node) -> Npc:
	return _npc(scene, "Mom")


func _npc(scene: Node, npc_name: String) -> Npc:
	var b := scene.find_child(npc_name, true, false) as Npc
	b.walk_speed = 400.0          # don't make the test watch him stroll
	b.got_stuck.connect(func(at: Vector2, target: Vector2) -> void:
		_failures.append("%s: stuck at %s heading for %s" % [scene.name, at, target]))
	return b


## Physics frames until cond() is true, or give up.
func _wait_for(cond: Callable, frames := 600) -> bool:
	for i in frames:
		if cond.call():
			return true
		await get_tree().physics_frame
	return cond.call()


func _run() -> void:
	var guard := 0
	while GameClock.is_paused() and guard < 600:
		await get_tree().process_frame
		guard += 1

	# --- 7 AM, the ranch: at the fence, wandering -----------------------------
	_set_hour(7)
	var ranch := await _load(RANCH)
	var bruce := _bruce(ranch)
	var nav := ranch.find_child("NpcNavigation", true, false) as NpcNavigation
	_check(nav.navigation_polygon != null and nav.navigation_polygon.get_polygon_count() > 0,
			"ranch navigation baked")
	_check(bruce.visible, "7 AM: Bruce is on the ranch")
	var fence := ranch.find_child("BruceFence", true, false) as Node2D
	var near_fence := func() -> bool:
		for m in fence.get_children():
			if bruce.global_position.distance_to(m.global_position) < 6.0:
				return true
		return false
	_check(near_fence.call(), "7 AM: Bruce starts at a fence point")

	# --- 9 AM: walks to the barn door and is gone -----------------------------
	GameClock.advance(120)
	_check(bruce.visible, "9 AM: still visible while walking off")
	var exit_barn := ranch.find_child("Exit_barn", true, false) as Node2D
	var start := bruce.global_position
	var ok := await _wait_for(func() -> bool: return not bruce.visible)
	_check(ok, "9 AM: Bruce leaves for the barn")
	_check(bruce.global_position.distance_to(exit_barn.global_position) < 6.0,
			"9 AM: he left by the barn door (at %s)" % bruce.global_position)
	_check(start.distance_to(exit_barn.global_position) > 100.0, "9 AM: he actually walked there")
	ranch.queue_free()
	await get_tree().process_frame

	# --- 12 PM, inside: nobody home; 1 PM: in the door and onto the couch ------
	_set_hour(12)
	var house := await _load(INTERIOR)
	bruce = _bruce(house)
	_check(not bruce.visible, "noon: Bruce isn't in the house")
	GameClock.advance(60)
	var seat := house.find_child("couch", true, false).get_node("Seat") as Seat
	ok = await _wait_for(func() -> bool: return seat.occupant == bruce)
	_check(ok, "1 PM: Bruce sits on the couch (at %s)" % bruce.global_position)
	_check(bruce.visible, "1 PM: Bruce is visible on the couch")
	_check(bruce.sprite.animation.begins_with("sit"), "1 PM: sitting pose (%s)" % bruce.sprite.animation)
	_check(not seat.can_interact(house.find_child("player", true, false)), "1 PM: player can't sit on Bruce")

	# --- 8 PM: off the couch, up the stairs ------------------------------------
	GameClock.advance(7 * 60)
	_check(seat.occupant == null, "8 PM: couch freed")
	ok = await _wait_for(func() -> bool: return not bruce.visible)
	_check(ok, "8 PM: Bruce heads upstairs")
	var stairs := house.find_child("Exit_ranch_second_floor_interior", true, false) as Node2D
	_check(bruce.global_position.distance_to(stairs.global_position) < 6.0,
			"8 PM: he left by the stairs (at %s)" % bruce.global_position)
	house.queue_free()
	await get_tree().process_frame

	# --- upstairs: up the stairs at 8 PM, into bed, asleep ----------------------
	_set_hour(19)
	var up := await _load(UPSTAIRS)
	bruce = _bruce(up)
	_check(not bruce.visible, "7 PM: Bruce isn't upstairs yet")
	GameClock.advance(60)
	var bed := up.find_child("bruceside", true, false) as Node2D
	ok = await _wait_for(func() -> bool: return bruce.is_asleep())
	_check(ok, "8 PM: Bruce gets into bed (at %s)" % bruce.global_position)
	_check(bruce.global_position.distance_to(bed.global_position) < 1.0, "8 PM: on his side of the bed")
	_check(bruce.sprite.visible and bruce.sprite.animation == &"sleep",
			"8 PM: sleeping (got %s)" % bruce.sprite.animation)
	_check(bruce.talk.process_mode == Node.PROCESS_MODE_DISABLED, "8 PM: can't talk to him asleep")
	var bed_node := bed.get_parent() as CanvasItem
	_check(bruce.z_index > bed_node.z_index, "8 PM: drawn over the bed (z %d vs bed %d)" % [bruce.z_index, bed_node.z_index])
	up.queue_free()
	await get_tree().process_frame

	# --- loading in later: already asleep; new day: up and gone -----------------
	_set_hour(22)
	up = await _load(UPSTAIRS)
	bruce = _bruce(up)
	_check(bruce.is_asleep() and bruce.visible, "10 PM: already asleep when you come upstairs")
	GameClock.minutes = 0
	EventBus.day_started.emit(GameClock.day)
	_check(not bruce.is_asleep() and not bruce.visible, "7 AM: out of bed and off to the fence")
	_check(bruce.sprite.visible, "7 AM: normal sprite back")
	up.queue_free()

	await _mom_good_day()
	await _mom_bad_day()
	Mom.set_can_care(true)

	_finished = true


func _near(npc: Node2D, scene: Node, marker: String) -> bool:
	var m := scene.find_child(marker, true, false) as Node2D
	return m != null and npc.global_position.distance_to(m.global_position) < 2.0


## Mom on a good day: cooking, TV, out chopping wood, dinner with Bruce,
## asleep on the couch.
func _mom_good_day() -> void:
	Mom.set_can_care(true)

	# --- 8 AM at the stove; 9 AM onto the couch ---
	_set_hour(8)
	var house := await _load(INTERIOR)
	var mom := _mom(house)
	_check(mom.visible and _near(mom, house, "MomStove"), "good 8 AM: Mom at the stove")
	_check(mom.sprite.animation == &"cook", "good 8 AM: cooking (got %s)" % mom.sprite.animation)
	GameClock.advance(60)
	var seat := house.find_child("couch", true, false).get_node("Seat") as Seat
	var ok := await _wait_for(func() -> bool: return seat.occupant == mom)
	_check(ok, "good 9 AM: Mom sits down for TV")

	# --- 1 PM: out the front door to chop wood ---
	GameClock.advance(4 * 60)
	_check(seat.occupant == null, "good 1 PM: off the couch")
	ok = await _wait_for(func() -> bool: return not mom.visible)
	_check(ok, "good 1 PM: Mom heads outside")
	_check(_near(mom, house, "Exit_ranch"), "good 1 PM: by the front door")
	house.queue_free()
	await get_tree().process_frame

	_set_hour(12)
	var ranch := await _load(RANCH)
	mom = _mom(ranch)
	_check(not mom.visible, "good noon: Mom isn't outside yet")
	GameClock.advance(60)
	ok = await _wait_for(func() -> bool: return mom.visible and _near(mom, ranch, "MomWoodpile"))
	_check(ok, "good 1 PM: Mom walks out to the woodpile (at %s)" % mom.global_position)
	_check(mom.sprite.animation == &"chop_right", "good 1 PM: chopping (got %s)" % mom.sprite.animation)
	ranch.queue_free()
	await get_tree().process_frame

	# --- 5 PM cooking, 6 PM everyone at the table ---
	_set_hour(17)
	house = await _load(INTERIOR)
	mom = _mom(house)
	var bruce := _bruce(house)
	_check(_near(mom, house, "MomStove") and mom.sprite.animation == &"cook", "good 5 PM: cooking dinner")
	GameClock.advance(60)
	# The house is loaded beside the test, not as the current scene, so Mom's
	# 6 PM call thinks you're out; undo that, it isn't what's being tested.
	GameState.skipped_family_dinner = false
	var mom_chair := house.find_child("MomChair", true, false).get_node("Seat") as Seat
	var bruce_chair := house.find_child("BruceChair", true, false).get_node("Seat") as Seat
	ok = await _wait_for(func() -> bool: return mom_chair.occupant == mom and bruce_chair.occupant == bruce)
	_check(ok, "good 6 PM: Mom and Bruce sit down to dinner")
	var dinner_open := false
	for chair_name in ["chair", "chair2"]:
		var chair := house.find_child(chair_name, true, false).get_node("Seat") as Seat
		var act := chair.current_activity()
		dinner_open = dinner_open or (act != null and act.family_dinner)
	_check(dinner_open, "good 6 PM: a free chair offers family dinner")

	# --- 10 PM: asleep on the couch, under the blanket ---
	seat = house.find_child("couch", true, false).get_node("Seat") as Seat
	GameClock.advance(4 * 60)
	var lie := house.find_child("CouchLieDown", true, false) as Node2D
	ok = await _wait_for(func() -> bool: return mom.is_asleep())
	_check(ok and mom.global_position.distance_to(lie.global_position) < 1.0, "good 10 PM: Mom asleep on the couch")
	_check((lie.get_node("Covers") as CanvasItem).visible, "good 10 PM: blanket over her")
	_check(seat.is_taken_by_mom() and Mom.sleeps_on_couch(), "good 10 PM: the couch is hers (seat agrees)")
	_check(mom.talk.process_mode == Node.PROCESS_MODE_DISABLED, "good 10 PM: can't talk to her asleep")
	house.queue_free()
	await get_tree().process_frame


## Mom on a bad day: breakfast, then out cold on the couch, then in bed with
## the TV; no family dinner.
func _mom_bad_day() -> void:
	Mom.set_can_care(true)
	_set_hour(10)
	var house := await _load(INTERIOR)
	var mom := _mom(house)
	var seat := house.find_child("couch", true, false).get_node("Seat") as Seat
	_check(seat.occupant == mom, "10 AM good: Mom on the couch")

	# The day turns bad while you watch: she lies down where she is.
	Mom.set_can_care(false)
	var ok := await _wait_for(func() -> bool: return mom.is_asleep())
	_check(ok, "turned bad: Mom passes out on the couch")
	_check(seat.occupant == null and seat.is_taken_by_mom(), "turned bad: couch is hers, not 'occupied'")
	var bruce := _bruce(house)
	_check(not bruce.visible, "bad 10 AM: Bruce is out in the barn as usual")

	# --- 1 PM: up to bed ---
	GameClock.advance(3 * 60)
	ok = await _wait_for(func() -> bool: return not mom.visible)
	_check(ok, "bad 1 PM: Mom goes upstairs")
	_check(_near(mom, house, "Exit_ranch_second_floor_interior"), "bad 1 PM: by the stairs")
	_check(not seat.is_taken_by_mom(), "bad 1 PM: couch is free again")

	# --- 6 PM: no dinner, no penalty; Bruce stays on the couch ---
	GameClock.minutes = (17 - GameClock.START_HOUR) * 60
	GameState.skipped_family_dinner = false
	GameClock.advance(60)
	_check(not GameState.skipped_family_dinner, "bad 6 PM: no dinner to miss")
	var chair := house.find_child("chair", true, false).get_node("Seat") as Seat
	var act := chair.current_activity()
	_check(act == null or not act.family_dinner, "bad 6 PM: no family dinner at the table")
	var bruce_chair := house.find_child("BruceChair", true, false).get_node("Seat") as Seat
	for i in 60:
		await get_tree().physics_frame
	_check(bruce_chair.occupant == null and seat.occupant == bruce, "bad 6 PM: Bruce stays on the couch")
	house.queue_free()
	await get_tree().process_frame

	# --- upstairs: lying awake with the TV, then asleep without getting up ---
	_set_hour(15)
	var up := await _load(UPSTAIRS)
	mom = _mom(up)
	var side := up.find_child("momside", true, false) as Node2D
	_check(mom.is_lying() and not mom.is_asleep(), "bad 3 PM: Mom lying awake in bed")
	_check(mom.global_position.distance_to(side.global_position) < 1.0, "bad 3 PM: on her side of the bed")
	_check(mom.talk.process_mode != Node.PROCESS_MODE_DISABLED, "bad 3 PM: you can talk to her")
	GameClock.minutes = (21 - GameClock.START_HOUR) * 60
	GameClock.advance(60)
	ok = await _wait_for(func() -> bool: return mom.is_asleep())
	_check(ok and mom.global_position.distance_to(side.global_position) < 1.0, "bad 10 PM: asleep, same spot")
	up.queue_free()
	await get_tree().process_frame
