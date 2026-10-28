class_name WorkbookBag
extends Interactable

## Mom's canvas bag: the workbooks she grades, and the teacher's edition with
## every answer in it. Placeholder downstairs until her room upstairs exists.
## While she's asleep the player can slip the answer key out (School owns the
## rules); while she's awake it's just her bag.


func get_prompt(_by: Node2D) -> String:
	if School.take_key_blocked_reason() == "":
		return "Take the answer key"
	return "Mom's workbook bag"


func _on_interact(_by: Node2D) -> void:
	var why := School.take_key_blocked_reason()
	if why == "":
		School.take_answer_key()
		EventBus.notice.emit("You ease the teacher's edition out from under her grade book. Back before she wakes up.")
	elif School.has_answer_key():
		EventBus.notice.emit("You already have it. Don't push your luck.")
	else:
		EventBus.notice.emit("Her bag. The answer key's in there. Not while she's awake.")
