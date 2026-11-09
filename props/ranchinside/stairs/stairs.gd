class_name Stairs
extends Interactable

#Goes up the stairs to the second floor of the house. 

@export_file("*.tscn") var target_scene: String = ""
@export var target_spawn: StringName = &""
@export var locked_prompt := "Locked"
@export var locked := false

func _ready() -> void:
	super()
	if prompt == "Look":
		prompt = "Go Upstairs"
		
		
func can_interact(by: Node2D) -> bool:
	return super(by) and not SceneRouter.is_travelling()
	
func get_prompt(by: Node2D) -> String:
	if locked:
		return locked_prompt
	return super(by)
	
func _on_interact(_by: Node2D) -> void:
	if locked:
		return
	if target_scene.is_empty():
		push_warning("Stairs '%s' has no target_scene set." % name)
		return
	SceneRouter.travel(target_scene, target_spawn)
	
	
