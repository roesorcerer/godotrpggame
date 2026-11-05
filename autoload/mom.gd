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

## She's asleep from this hour on. Until her daily condition roll exists,
## this is the only time she's out cold.
const SLEEP_HOUR := 22


func _ready() -> void:
	EventBus.anchor_reached.connect(_on_anchor_reached)


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
	return GameClock.clock_hour() >= SLEEP_HOUR


func _on_anchor_reached(anchor: StringName) -> void:
	if anchor == &"dinner":
		_serve_dinner()


## 6 PM: Mom puts dinner on. Miss it (not in the house) and you have to feed
## yourself: her plate at the table is gone (SeatActivity.family_dinner) and
## skipped_family_dinner stays set all day, even if you cook. Tonight's sleep
## is worse for it (GameState.begin_new_day).
## TODO(A-19): dinner needles - 70% chance; missing dinner should make
## them worse (more guilt).
func _serve_dinner() -> void:
	EventBus.notice.emit("Dinner. Mom makes Oscar's plate.")
	if not _player_in_house():
		GameState.skipped_family_dinner = true


## The house scene is loaded (ranch_interior.tscn -> "ranch_interior").
func _player_in_house() -> bool:
	var scene := get_tree().current_scene
	return scene != null and scene.scene_file_path.get_file().get_basename() == "ranch_interior"
