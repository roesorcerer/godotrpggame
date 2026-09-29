class_name Desk
extends Interactable

## The kitchen table, which is also the classroom. Coursework happens here, and
## the room's state is in your way: you cannot work at a table covered in stuff.

@export var subject: StringName = &"civics"
@export var room: StringName = &"kitchen"

## Above this much grime the table isn't usable.
@export_range(0, 5) var max_grime := 4


func _ready() -> void:
	super()
	prompt = "Do coursework"


func can_interact(by: Node2D) -> bool:
	return super(by)


func get_prompt(_by: Node2D) -> String:
	if MessSystem.grime(room) > max_grime:
		return "Can't work at this table"
	var work := CourseworkSystem.next_assignment(subject)
	if work == null:
		return "Packet finished"
	var blocked := CourseworkSystem.blocked_reason(work)
	if blocked != "":
		return "%s (%s)" % [work.title, blocked]
	return "%s  -%d gas, %dm  ·  %s" % [
		work.title, work.gas_cost, work.minutes, CourseworkSystem.concentration_label()]


func _on_interact(_by: Node2D) -> void:
	if MessSystem.grime(room) > max_grime:
		return
	var work := CourseworkSystem.next_assignment(subject)
	if work == null:
		return
	CourseworkSystem.study(work)
