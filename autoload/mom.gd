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
