class_name Desk
extends ChoreSpot

## The kitchen table, which is also the classroom. Schoolwork is just one more
## thing on Mom's list - she checks the workbook every night.


func _ready() -> void:
	if only_chore == &"":
		only_chore = &"schoolwork"
	super()
