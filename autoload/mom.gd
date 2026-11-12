extends Node

## Doris. Her mood is the one thing chores move. Like a Stardew friendship it
## can be ignored - nothing locks - but she gets meaner the longer you do.
## State lives in GameState.doris; this node is the rules.

const START_MOOD := 60
const MAX_MOOD := 100

## Lowest mood for each tier, best first.
const TIERS := [
	{"min": 85, "id": &"warm",  "label": "Warm"},
	{"min": 65, "id": &"fine",  "label": "Fine"},
	{"min": 45, "id": &"short", "label": "Short with you"},
	{"min": 25, "id": &"cold",  "label": "Cold"},
	{"min": 0,  "id": &"mean",  "label": "Mean"},
]

## At or above this she makes breakfast, which lifts tomorrow's Gas.
const BREAKFAST_MOOD := 65

## On a good day she's asleep on the couch from this hour on.
const SLEEP_HOUR := 22

## On a bad day (she can't care, see can_care()) she's out of it from this
## hour on: asleep on the couch until BAD_DAY_BED_HOUR, then in bed upstairs.
const BAD_DAY_OUT_HOUR := 9
const BAD_DAY_BED_HOUR := 13

## Dev-only: flips can_care() so bad days can be tested before the drinking
## model exists.
const DEBUG_TOGGLE_KEY := KEY_F8


func _ready() -> void:
	EventBus.anchor_reached.connect(_on_anchor_reached)


## --- good days and bad days (A-26) ------------------------------------------
## A good day: Mom is able to look after the house and Oscar. A bad day: she's
## hungover or passed out (GDD 5.7). Her schedule (mom.tscn), family dinner
## and who sleeps on the couch all follow this.
## TODO(phase-b): set by the drinking-night roll (GDD 5.15, M6) and her dates;
## until then it only changes through set_can_care() / the debug toggle.

func can_care() -> bool:
	return bool(GameState.doris.get("can_care", true))


func set_can_care(value: bool) -> void:
	if value == can_care():
		return
	GameState.doris["can_care"] = value
	EventBus.mom_can_care_changed.emit(value)


func _unhandled_key_input(event: InputEvent) -> void:
	if OS.is_debug_build() and event is InputEventKey and event.pressed and not event.echo 			and (event as InputEventKey).keycode == DEBUG_TOGGLE_KEY:
		set_can_care(not can_care())
		EventBus.notice.emit("[debug] Mom: %s day" % ("good" if can_care() else "bad"))


func mood() -> int:
	return int(GameState.doris.get("mood", START_MOOD))


func change(delta: int) -> void:
	if delta == 0:
		return
	GameState.doris["mood"] = clampi(mood() + delta, 0, MAX_MOOD)
	EventBus.mom_mood_changed.emit(mood())


func _tier() -> Dictionary:
	for t in TIERS:
		if mood() >= int(t["min"]):
			return t
	return TIERS[-1]

func tier() -> StringName:
	return _tier()["id"]

func tier_label() -> String:
	return _tier()["label"]


func makes_breakfast() -> bool:
	return mood() >= BREAKFAST_MOOD


## Asleep (or, once the condition roll exists, passed out): she won't notice
## what goes on in the house.
func is_asleep() -> bool:
	return GameClock.clock_hour() >= (SLEEP_HOUR if can_care() else BAD_DAY_OUT_HOUR)


## Asleep on the living-room couch right now (the couch is hers, not yours).
## Mom's NPC schedule lies down there at the same hours.
func sleeps_on_couch() -> bool:
	var hour := GameClock.clock_hour()
	if can_care():
		return hour >= SLEEP_HOUR
	return hour >= BAD_DAY_OUT_HOUR and hour < BAD_DAY_BED_HOUR


func _on_anchor_reached(anchor: StringName) -> void:
	if anchor == &"dinner":
		_serve_dinner()


## 6 PM: Mom puts dinner on. Miss it (not in the house) and you have to feed
## yourself: her plate at the table is gone (SeatActivity.family_dinner) and
## skipped_family_dinner stays set all day, even if you cook. Tonight's sleep
## is worse for it (GameState.begin_new_day).
## TODO(A-19): dinner needles - 70% chance; missing dinner should make
## them worse (more guilt).
## On a bad day there's no dinner to miss: no plate, and no penalty for it.
func _serve_dinner() -> void:
	if not can_care():
		EventBus.notice.emit("Six o'clock. Nobody's cooking. Mom's door is shut and the TV's on behind it.")
		return
	EventBus.notice.emit("Dinner. Mom makes Oscar's plate.")
	if not _player_in_house():
		GameState.skipped_family_dinner = true


## Every floor of the house, by scene file name (ranch_interior.tscn ->
## "ranch_interior"). Add a scene here when the house grows a room.
const HOUSE_SCENES := [&"ranch_interior", &"ranch_second_floor_interior"]

## The player is on any floor of the house.
func _player_in_house() -> bool:
	var scene := get_tree().current_scene
	return scene != null and StringName(scene.scene_file_path.get_file().get_basename()) in HOUSE_SCENES
