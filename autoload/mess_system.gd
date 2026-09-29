extends Node

## The house is the farm. Rooms carry grime (rises daily, cheap to clear) and
## clutter (rises weekly, expensive, yields sellable junk). State lives in
## GameState.rooms; this node is the rules that move it.

const MAX_LEVEL := 5

## grime 2 is the hosting ceiling - above it you can't have anyone over, which
## is the strongest lever in the design. See §04.
const HOSTING_GRIME_LIMIT := 2

## Room catalog. `daily_grime` is how fast it gets away from you; the living
## room is worst because Bruce smokes in there.
const ROOMS := {
	&"kitchen":      {"name": "Kitchen",      "daily_grime": 1, "weekly_clutter": 1},
	&"living_room":  {"name": "Living room",  "daily_grime": 2, "weekly_clutter": 1},
	&"bathroom":     {"name": "Bathroom",     "daily_grime": 1, "weekly_clutter": 0},
	&"your_room":    {"name": "Your room",    "daily_grime": 1, "weekly_clutter": 0},
	&"doris_room":   {"name": "Doris's room", "daily_grime": 1, "weekly_clutter": 1},
	&"bruce_room":   {"name": "Bruce's room", "daily_grime": 1, "weekly_clutter": 2},
	&"porch":        {"name": "Porch",        "daily_grime": 0, "weekly_clutter": 2},
}

## What you moved into. A dilapidated ranch belonging to a man who keeps things
## means day 1 already has work waiting - and the living room starts above the
## hosting limit, so "clean up enough to have someone over" is the first real
## goal the player sets themselves.
const STARTING_STATE := {
	&"kitchen":     {"grime": 2, "clutter": 2},
	&"living_room": {"grime": 3, "clutter": 4},
	&"bathroom":    {"grime": 2, "clutter": 1},
	&"your_room":   {"grime": 1, "clutter": 3},
	&"doris_room":  {"grime": 1, "clutter": 1},
	&"bruce_room":  {"grime": 2, "clutter": 5},
	&"porch":       {"grime": 0, "clutter": 4},
}

## Set true by Bruce's haul (M5). Makes clutter accelerate - the hoard feeds
## itself, which the player will feel without ever being told.
var hauled_this_week := false


func _ready() -> void:
	EventBus.day_started.connect(_on_day_started)
	if GameState.rooms.is_empty():
		seed_new_game()


## Lay down the move-in state. A loaded save overwrites GameState.rooms
## wholesale, so this only ever applies to a fresh start.
func seed_new_game() -> void:
	for id in STARTING_STATE:
		var room := get_room(id)
		room["grime"] = int(STARTING_STATE[id]["grime"])
		room["clutter"] = int(STARTING_STATE[id]["clutter"])
		EventBus.room_state_changed.emit(id)


## --- reading and writing room state ---------------------------------------

func room_ids() -> Array:
	return ROOMS.keys()

func room_name(room_id: StringName) -> String:
	return ROOMS.get(room_id, {}).get("name", String(room_id))

func get_room(room_id: StringName) -> Dictionary:
	if not GameState.rooms.has(room_id):
		GameState.rooms[room_id] = {"grime": 0, "clutter": 0, "repairs": []}
	return GameState.rooms[room_id]

func grime(room_id: StringName) -> int:
	return int(get_room(room_id).get("grime", 0))

func clutter(room_id: StringName) -> int:
	return int(get_room(room_id).get("clutter", 0))

func add_grime(room_id: StringName, amount: int) -> void:
	var r := get_room(room_id)
	r["grime"] = clampi(int(r["grime"]) + amount, 0, MAX_LEVEL)
	EventBus.room_state_changed.emit(room_id)

func add_clutter(room_id: StringName, amount: int) -> void:
	var r := get_room(room_id)
	r["clutter"] = clampi(int(r["clutter"]) + amount, 0, MAX_LEVEL)
	EventBus.room_state_changed.emit(room_id)


## --- the consequences that make a dirty house matter ----------------------

## Above the limit you cannot have anyone over. This is the lever that makes
## housework tax your social life directly.
func can_host() -> bool:
	return grime(&"living_room") <= HOSTING_GRIME_LIMIT

func worst_grime() -> int:
	var worst := 0
	for id in ROOMS:
		worst = maxi(worst, grime(id))
	return worst

func total_grime() -> int:
	var total := 0
	for id in ROOMS:
		total += grime(id)
	return total

func total_clutter() -> int:
	var total := 0
	for id in ROOMS:
		total += clutter(id)
	return total

## Rough 0-1 measure of how far gone the house is, for UI.
func squalor() -> float:
	var ceiling := float(ROOMS.size() * MAX_LEVEL * 2)
	return clampf(float(total_grime() + total_clutter()) / ceiling, 0.0, 1.0)


## --- the daily tick -------------------------------------------------------

func _on_day_started(day: int) -> void:
	if day <= 1:
		return                      # you get one clean morning

	for id in ROOMS:
		var spec: Dictionary = ROOMS[id]
		add_grime(id, int(spec["daily_grime"]))

		# An Under day means the kitchen and bathroom get away from everyone.
		if GameState.doris.get("today", &"steady") == &"under" and id in [&"kitchen", &"bathroom"]:
			add_grime(id, 1)

	# Clutter creeps once a week, faster if Bruce brought a load home.
	if (day - 1) % 7 == 0:
		for id in ROOMS:
			var weekly := int(ROOMS[id]["weekly_clutter"])
			if weekly > 0:
				add_clutter(id, weekly + (1 if hauled_this_week else 0))
		hauled_this_week = false
