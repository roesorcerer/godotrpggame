class_name Bed
extends Interactable

## Ends the day. The clock's own midnight rollover is the involuntary version
## of this; here the player chooses, which is why it rests them properly.

@export var too_early_hour := 20   ## to allow sleeping from 20:00


func _ready() -> void:
	super()
	if prompt == "Look":
		prompt = "Go to sleep"


func get_prompt(by: Node2D) -> String:
	if GameClock.clock_hour() < too_early_hour:
		return "Too early to sleep"
	return super(by)


func _on_interact(_by: Node2D) -> void:
	if GameClock.clock_hour() < too_early_hour:
		return
	EventBus.interaction_prompt.emit("")
	GameClock.end_day(false)
