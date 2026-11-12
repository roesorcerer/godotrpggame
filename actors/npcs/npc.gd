class_name Npc
extends CharacterBody2D

## An NPC that follows a daily schedule (see ScheduleBlock).
##
## Put one instance in every scene the NPC can be in (the ranch, each floor of
## the house). Each copy looks at the clock: if the current block is in this
## scene it shows up at its spot, otherwise it hides. Time only moves on
## actions, so a copy reacts when GameClock.advance() crosses a block's
## start_hour while you're in the room: it walks out, walks in, or walks
## across to its new spot.
##
## Ways in and out are Marker2D nodes named "Exit_<place>": the spot in THIS
## scene you'd head for to get to <place>. Leaving for the barn, the NPC walks
## to Exit_barn and disappears; arriving from the barn, it appears at
## Exit_barn and walks to its spot. With no matching marker it just pops
## in or out. Walking uses the scene's NpcNavigation; without one it goes in
## a straight line.

const EXIT_PREFIX := "Exit_"

## Pause at each wander point, in seconds (looks like work).
const WANDER_PAUSE := Vector2(2.5, 6.0)

## No closer to the target after this long = stuck; jump to it.
const STUCK_SECONDS := 2.0

## ScheduleBlock.pose values that lie down instead of playing an animation.
const SLEEP_POSE := &"sleep"          ## asleep
const LIE_POSE := &"lie"              ## lying awake (in bed with the TV on)

## A freshly loaded scene's navmesh takes a few frames to bake and sync;
## wait this long for it before walking without one.
const NAV_WAIT_SECONDS := 1.0

## Couldn't make progress and jumped to where it was going. Watch for this
## when placing markers: it means the way there is blocked.
signal got_stuck(at: Vector2, target: Vector2)

@export var schedule: Array[ScheduleBlock] = []
@export var walk_speed := 40.0

## Where the body goes on a Seat, relative to Seat.sit_position(). This
## sprite is centred on the node (the player's sits on its feet), so it
## needs lifting onto the cushion.
@export var sit_nudge := Vector2(0, -8)

@export_group("Lying down")
## Asleep: where the centre of the head goes, relative to the bed marker
## (the pillow is above it). Used with the "sleep" animation.
@export var sleep_head_offset := Vector2(0, -8)

## Awake ("lie" pose, or asleep with no "sleep" animation): the rows of the
## idle_down frame that show above the covers (x = first row, y = how many)
## and where their centre goes relative to the marker.
@export var awake_head_rows := Vector2i(13, 11)
@export var awake_head_offset := Vector2(0, -3)
@export_group("")

## Where the feet are, relative to the node (the centre of the collision
## capsule). Paths are planned for the feet, since that's what bumps into
## things; this sprite's origin is its middle, not its feet.
@export var feet_offset := Vector2(0, 8)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim_tree: AnimationTree = $Animation/AnimationTree
@onready var talk: NpcTalk = get_node_or_null("Talk") as NpcTalk
@onready var move_state_machine: AnimationNodeStateMachinePlayback = \
		anim_tree.get("parameters/MoveStateMachine/playback")

var block: ScheduleBlock = null          ## the block we're acting out
var last_direction := Vector2.DOWN

## Work queue: each step is [kind, arg]. "appear" pos, "walk" pos,
## "vanish", "settle" block. _physics_process runs the front one.
var _steps: Array = []
var _walk_target := Vector2.ZERO
var _path := PackedVector2Array()        ## node positions still to walk through
var _walk_started := false
var _best_distance := INF
var _nav_wait := 0.0
var _stuck_time := 0.0

var _seat: Seat = null
var _lying := false                      ## in bed or on the couch
var _awake := false                      ## lying with eyes open ("lie" pose)
var _covers: CanvasItem = null           ## the blanket shown while lying here
var _head: Sprite2D = null               ## head on the pillow, made on first need
var _sprite_rest := Vector2.ZERO         ## where the sprite sits when standing
var _zzz: Label = null
var _zzz_tween: Tween = null
var _wander_points: Array[Vector2] = []
var _wander_wait := 0.0
var _default_small_talk: Array[String] = []


func _ready() -> void:
	anim_tree.active = true
	_sprite_rest = sprite.position
	if talk != null:
		_default_small_talk = talk.small_talk.duplicate()
	EventBus.time_advanced.connect(func(_m: int) -> void: _on_clock_moved())
	# A good day turning bad (or back) re-plans the day, like the clock moving.
	EventBus.mom_can_care_changed.connect(func(_c: bool) -> void: _on_clock_moved())
	EventBus.day_started.connect(func(_d: int) -> void: snap())
	# Let the scene finish loading (markers, seats) before looking for them.
	snap.call_deferred()


## --- schedule --------------------------------------------------------------

## Which block is running at `hour` (24h), on a good or bad day.
func block_at(hour: int, good_day: bool = Mom.can_care()) -> ScheduleBlock:
	var current: ScheduleBlock = null
	var latest: ScheduleBlock = null
	for b in schedule:
		if not _applies(b, good_day):
			continue
		if latest == null or b.start_hour > latest.start_hour:
			latest = b
		if b.start_hour <= hour and (current == null or b.start_hour > current.start_hour):
			current = b
	# Earlier than the first block: last night's block is still running.
	return current if current != null else latest


func _applies(b: ScheduleBlock, good_day: bool) -> bool:
	match b.days:
		1: return good_day
		2: return not good_day
	return true


func current_block() -> ScheduleBlock:
	return block_at(GameClock.clock_hour())


## This scene's place id: its file name (ranch_interior.tscn -> &"ranch_interior").
func here() -> StringName:
	var root := owner if owner != null else get_tree().current_scene
	return StringName(root.scene_file_path.get_file().get_basename()) if root != null else &""


func is_present() -> bool:
	return visible


## Put the NPC straight where the clock says, no walking (scene load, new day).
func snap() -> void:
	_steps.clear()
	block = current_block()
	if block == null or block.place != here():
		_vanish()
		return
	var spot := _spot_node(block)
	_appear(_approach_point(spot) if spot != null else global_position)
	_settle(block)


func _on_clock_moved() -> void:
	var next := current_block()
	if next == block or next == null:
		return
	var prev := block
	block = next
	_plan_transition(prev, next)


## Queue up the walk from the old block to the new one.
func _plan_transition(prev: ScheduleBlock, next: ScheduleBlock) -> void:
	_steps.clear()
	# Same spot, new pose (lying awake -> asleep): no getting up first.
	if prev != null and prev.place == here() and next.place == here() and prev.spot == next.spot:
		_steps.append(["settle", next])
		return
	_get_up()
	_wander_points.clear()
	_walk_target = Vector2.INF       # drop any walk in progress
	var was_here := prev != null and prev.place == here()
	var is_here := next.place == here()
	var spot := _spot_node(next)

	if is_here:
		if not was_here:
			var door := _exit_toward(prev.place if prev != null else &"")
			_steps.append(["appear", door.global_position if door != null
					else (spot.global_position if spot != null else global_position)])
		if spot != null:
			_steps.append(["walk", _approach_point(spot)])
		_steps.append(["settle", next])
	elif was_here:
		var door := _exit_toward(next.place)
		if door != null:
			_steps.append(["walk", door.global_position])
		_steps.append(["vanish", null])
	else:
		# Passing through: in one door, out the other (barn -> house across the yard).
		var from := _exit_toward(prev.place if prev != null else &"")
		var to := _exit_toward(next.place)
		if from != null and to != null:
			_steps.append(["appear", from.global_position])
			_steps.append(["walk", to.global_position])
		_steps.append(["vanish", null])


## --- finding things in the scene -------------------------------------------

func _scene_root() -> Node:
	return owner if owner != null else get_tree().current_scene


func _find(node_name: StringName) -> Node:
	if node_name == &"":
		return null
	var root := _scene_root()
	return root.find_child(String(node_name), true, false) if root != null else null


func _spot_node(b: ScheduleBlock) -> Node2D:
	var node := _find(b.spot) as Node2D
	if node == null and b.spot != &"" and b.place == here():
		push_warning("%s: spot '%s' not found in %s." % [name, b.spot, here()])
	return node


func _exit_toward(place: StringName) -> Node2D:
	return _find(StringName(EXIT_PREFIX + String(place))) as Node2D if place != &"" else null


func _seat_of(spot: Node) -> Seat:
	if spot is Seat:
		return spot
	for child in spot.get_children():
		if child is Seat:
			return child
	return null


## Where to walk to before settling: a seat's sit position, the first wander
## point, or the spot itself.
func _approach_point(spot: Node2D) -> Vector2:
	var seat := _seat_of(spot)
	if seat != null:
		return seat.sit_position()
	for child in spot.get_children():
		if child is Marker2D:
			return (child as Marker2D).global_position
	return spot.global_position


## --- doing things ----------------------------------------------------------

func _physics_process(delta: float) -> void:
	# Menus, dialogue and scene fades stop the clock; everyone waits.
	if GameClock.is_paused():
		return
	if not _steps.is_empty():
		_run_step(delta)
	elif not _wander_points.is_empty():
		_wander(delta)


## Runs steps until one needs more frames (a walk in progress), so arriving
## and starting the pose happen in the same frame - no flash of idle.
func _run_step(delta: float) -> void:
	while not _steps.is_empty():
		var step: Array = _steps.front()
		match step[0]:
			"appear":
				_appear(step[1])
			"walk":
				if not _walk(step[1], delta):
					return
			"settle":
				_settle(step[1])
			"vanish":
				_vanish()
		_steps.pop_front()


func _appear(pos: Vector2) -> void:
	global_position = pos
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	_set_body_enabled(true)
	_idle()


## Hidden and out of the physics world: no collision, no talk prompt.
## Still hears the clock, so it can walk back in later.
func _vanish() -> void:
	_get_up()
	_wander_points.clear()
	visible = false
	velocity = Vector2.ZERO
	_set_body_enabled(false)


func _set_body_enabled(on: bool) -> void:
	$CollisionShape2D.set_deferred("disabled", not on)
	if talk != null:
		talk.process_mode = Node.PROCESS_MODE_INHERIT if on and (block == null or block.can_talk) \
				else Node.PROCESS_MODE_DISABLED


## Start what the block does once we're at the spot.
func _settle(b: ScheduleBlock) -> void:
	velocity = Vector2.ZERO
	if talk != null:
		talk.small_talk = b.small_talk if not b.small_talk.is_empty() else _default_small_talk
	_set_body_enabled(true)
	var spot := _spot_node(b)
	if spot == null:
		_idle(b.pose)
		return

	if b.pose == SLEEP_POSE or b.pose == LIE_POSE:
		_lie_down(spot, b.pose == LIE_POSE)
		return

	var seat := _seat_of(spot)
	if seat != null:
		if seat.occupant == null or seat.occupant == self:
			_sit(seat, b.pose if b.pose != &"" else &"sit_legsout")
		else:
			_idle(b.pose)     # someone's in it; stand there and wait it out
		return

	for child in spot.get_children():
		if child is Marker2D:
			_wander_points.append((child as Marker2D).global_position)
	if not _wander_points.is_empty():
		_wander_wait = randf_range(WANDER_PAUSE.x, WANDER_PAUSE.y)
		_walk_started = false
	_idle(b.pose)


func _sit(seat: Seat, pose: StringName) -> void:
	_seat = seat
	seat.occupant = self
	anim_tree.active = false
	$CollisionShape2D.set_deferred("disabled", true)   # he's in the couch's collision
	global_position = seat.sit_position() + sit_nudge
	_draw_above(seat.get_parent() as CanvasItem)       # over the cushions
	sprite.play(seat.seated_animation(self, pose))


## Lie down at a bed or couch marker: the body is under the covers and only
## the head shows. Asleep plays the "sleep" animation (head on the pillow,
## eyes closed) if the sheet has one; awake shows head and shoulders cut from
## the idle_down frame.
func _lie_down(spot: Node2D, awake: bool) -> void:
	_lying = true
	_awake = awake
	global_position = spot.global_position
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)   # inside the bed's collision
	_draw_above(spot.get_parent() as CanvasItem)       # over the bed, not under it
	anim_tree.active = false
	sprite.stop()
	_show_covers(spot.get_node_or_null("Covers") as CanvasItem)

	if not awake and sprite.sprite_frames.has_animation(&"sleep"):
		if _head != null:
			_head.visible = false
		sprite.visible = true
		sprite.play(&"sleep")
		sprite.position = _centre_on(sprite.sprite_frames.get_frame_texture(&"sleep", 0), sleep_head_offset)
	else:
		sprite.visible = false
		if _head == null:
			_head = Sprite2D.new()
			_head.name = "LyingHead"
			_head.centered = false
			add_child(_head)
		_head.texture = _head_texture()
		var size := _head.texture.get_size() if _head.texture != null else Vector2.ZERO
		_head.position = (awake_head_offset - size / 2.0).round()
		_head.visible = true
	_show_zzz(not awake)


## Sprite position (it's centred on its frame) that puts the drawn part of
## `frame` centred on `point`, on whole pixels so it doesn't shimmer.
func _centre_on(frame: Texture2D, point: Vector2) -> Vector2:
	if frame == null:
		return point
	var used := Rect2(frame.get_image().get_used_rect())
	return (point - (used.get_center() - frame.get_size() / 2.0)).round()


func _show_covers(covers: CanvasItem) -> void:
	if _covers != null and _covers != covers:
		_covers.visible = false
	_covers = covers
	if _covers != null:
		_covers.visible = true


## One draw layer above `thing` (the couch, the bed), whatever z_index it
## was given in the scene.
func _draw_above(thing: CanvasItem) -> void:
	z_index = (_effective_z(thing) if thing != null else 0) + 1 - _effective_z(get_parent() as CanvasItem)


func _effective_z(item: CanvasItem) -> int:
	var z := 0
	while item != null:
		z += item.z_index
		if not item.z_as_relative:
			break
		item = item.get_parent() as CanvasItem
	return z


func _head_texture() -> Texture2D:
	var frame := sprite.sprite_frames.get_frame_texture(&"idle_down", 0)
	if frame == null:
		return null
	var head := AtlasTexture.new()
	head.atlas = frame
	head.region = Rect2(0, awake_head_rows.x, frame.get_width(), awake_head_rows.y)
	return head


## A small "z z" drifting up off the pillow while asleep.
func _show_zzz(on: bool) -> void:
	if _zzz_tween != null:
		_zzz_tween.kill()
		_zzz_tween = null
	if not on:
		if _zzz != null:
			_zzz.visible = false
		return
	if _zzz == null:
		_zzz = Label.new()
		_zzz.name = "Zzz"
		_zzz.text = "z z"
		_zzz.add_theme_font_size_override("font_size", 8)
		_zzz.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
		_zzz.add_theme_color_override("font_outline_color", Color(0.15, 0.15, 0.25))
		_zzz.add_theme_constant_override("outline_size", 2)
		add_child(_zzz)
	_zzz.visible = true
	var rest := sleep_head_offset + Vector2(4, -14)
	_zzz.position = rest
	_zzz.modulate.a = 0.0
	_zzz_tween = create_tween().set_loops()
	_zzz_tween.tween_property(_zzz, "modulate:a", 1.0, 0.6)
	_zzz_tween.parallel().tween_property(_zzz, "position", rest + Vector2(3, -6), 1.8)
	_zzz_tween.tween_property(_zzz, "modulate:a", 0.0, 0.6)
	_zzz_tween.tween_callback(func() -> void: _zzz.position = rest)


func is_asleep() -> bool:
	return _lying and not _awake


## In bed or on the couch, asleep or not.
func is_lying() -> bool:
	return _lying


## Off the seat or out of bed, onto the nearest walkable floor.
func _get_up() -> void:
	if _seat == null and not _lying:
		return
	if _seat != null and _seat.occupant == self:
		_seat.release()
	_seat = null
	if _lying:
		_lying = false
		_awake = false
		sprite.visible = true
		sprite.position = _sprite_rest
		if _head != null:
			_head.visible = false
		_show_covers(null)
		_show_zzz(false)
	z_index = 0
	sprite.stop()
	anim_tree.active = true
	# Step out of the seat's or bed's collision.
	var map := _nav_map()
	if map.is_valid():
		global_position = NavigationServer2D.map_get_closest_point(map, global_position + feet_offset) - feet_offset
	$CollisionShape2D.set_deferred("disabled", false)
	_idle()


## Walk between wander points: pause, pick another, go.
func _wander(delta: float) -> void:
	if not _walk_started:
		_wander_wait -= delta
		if _wander_wait > 0.0:
			return
		var choices := _wander_points.filter(func(p: Vector2) -> bool:
			return p.distance_to(global_position) > 8.0)
		if choices.is_empty():
			choices = _wander_points
		_walk_target = choices.pick_random()
		_walk_started = true
		_begin_walk(_walk_target)
	if _walk(_walk_target, delta):
		_walk_started = false
		_wander_wait = randf_range(WANDER_PAUSE.x, WANDER_PAUSE.y)
		_idle(block.pose if block != null else &"")


func _begin_walk(target: Vector2) -> void:
	_walk_target = target
	_best_distance = INF
	_stuck_time = 0.0
	_nav_wait = 0.0
	_path = PackedVector2Array()
	var map := _nav_map()
	if map.is_valid():
		# Planned at the feet, walked at the node: shift there and back.
		for p in NavigationServer2D.map_get_path(map, global_position + feet_offset,
				target + feet_offset, true):
			_path.append(p - feet_offset)
		if not _path.is_empty():
			_path.remove_at(0)       # that's where we're standing


## The scene's baked NpcNavigation, or an invalid RID if it has none (yet).
func _nav_map() -> RID:
	var map := get_world_2d().navigation_map
	if NavigationServer2D.map_get_regions(map).is_empty() or NavigationServer2D.map_get_iteration_id(map) == 0:
		return RID()
	return map


func _scene_has_navigation() -> bool:
	var root := _scene_root()
	return root != null and not root.find_children("*", "NpcNavigation", true, false).is_empty()


## One frame of walking toward `target`. True once there.
func _walk(target: Vector2, delta: float) -> bool:
	if target != _walk_target:
		_begin_walk(target)

	var distance := global_position.distance_to(target)
	if distance <= 2.0:
		_arrive(target)
		return true

	# Navmesh still baking: wait for it rather than walk into the furniture.
	if _path.is_empty() and _scene_has_navigation() and _nav_wait < NAV_WAIT_SECONDS:
		_nav_wait += delta
		var waited := _nav_wait
		_begin_walk(target)
		_nav_wait = waited
		return false

	var step := walk_speed * delta
	if not _path.is_empty():
		# On the navmesh: it already keeps clear of walls and furniture, so
		# move straight along it (no getting wedged on the player either).
		var next := _path[0]
		var dir := global_position.direction_to(next)
		_animate_walk(dir)
		if global_position.distance_to(next) <= step:
			global_position = next
			_path.remove_at(0)
			if _path.is_empty():
				# As close as the navmesh gets (a seat is inside the couch's
				# collision); the last bit is a hop.
				_arrive(target)
				return true
		else:
			global_position += dir * step
		return false

	# No navmesh: straight at it, with collisions.
	var dir := global_position.direction_to(target)
	velocity = dir * walk_speed
	move_and_slide()
	_animate_walk(dir)
	if distance < _best_distance - 0.5:
		_best_distance = distance
		_stuck_time = 0.0
	else:
		_stuck_time += delta
		if _stuck_time > STUCK_SECONDS:
			got_stuck.emit(global_position, target)
			push_warning("%s stuck at %s on the way to %s; jumping there." % [name, global_position, target])
			_arrive(target)       # wedged on something; don't stand there forever
			return true
	return false


func _arrive(target: Vector2) -> void:
	global_position = target
	velocity = Vector2.ZERO
	_walk_target = Vector2.INF       # the next walk plans afresh
	_path.clear()
	_idle()


## --- animation -------------------------------------------------------------

func _animate_walk(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		return
	last_direction = dir
	var blend := _blend_dir(dir)
	anim_tree.active = true          # a pose (cooking, chopping) had it off
	move_state_machine.travel("Walk")
	anim_tree.set("parameters/MoveStateMachine/Walk/blend_position", blend)
	anim_tree.set("parameters/MoveStateMachine/Idle/blend_position", blend)


## Idle facing the last way we walked, or play `pose` straight on the sprite.
func _idle(pose: StringName = &"") -> void:
	if _seat != null or _lying:
		return
	if pose != &"" and sprite.sprite_frames.has_animation(pose):
		anim_tree.active = false
		sprite.play(pose)
		return
	anim_tree.active = true
	move_state_machine.travel("Idle")
	anim_tree.set("parameters/MoveStateMachine/Idle/blend_position", _blend_dir(last_direction))


## The blend spaces only have the 4 directions; pick the dominant axis.
func _blend_dir(dir: Vector2) -> Vector2:
	if absf(dir.x) > absf(dir.y):
		return Vector2(signf(dir.x), 0)
	return Vector2(0, signf(dir.y) if dir.y != 0.0 else 1.0)
