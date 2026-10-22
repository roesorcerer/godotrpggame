class_name NpcTalk
extends Interactable

## Put this (an Area2D with a CollisionShape2D) on an NPC so the player can
## press E to talk. Quests decide what gets said first - finishing a "talk to"
## goal, then handing over a new quest - otherwise the NPC makes small talk.

## Matches QuestData.giver / goal_target and Data.NPC_NAMES.
@export var npc_id: StringName = &""

## Said when no quest has anything to say; one is picked at random.
@export_multiline var small_talk: Array[String] = []


func _ready() -> void:
	super()
	EventBus.quests_changed.connect(_update_prompt)
	_update_prompt()


func display_name() -> String:
	return Data.NPC_NAMES.get(npc_id, String(npc_id).capitalize())


func _update_prompt() -> void:
	prompt = "Talk to %s" % display_name()
	if QuestSystem.givers_with_offers().has(npc_id):
		prompt += "  (!)"


func _on_interact(_by: Node2D) -> void:
	var line := QuestSystem.talk_to(npc_id)
	if line == "" and not small_talk.is_empty():
		line = small_talk.pick_random()
	if line != "":
		EventBus.npc_said.emit(display_name(), line, portrait())


## Head and shoulders from the NPC's idle_down frame, for the speech box.
## Null if the NPC has no AnimatedSprite2D next to this node.
func portrait() -> Texture2D:
	var sprite := get_parent().get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if sprite == null or sprite.sprite_frames == null:
		return null
	var anim := &"idle_down" if sprite.sprite_frames.has_animation(&"idle_down") else sprite.animation
	var frame := sprite.sprite_frames.get_frame_texture(anim, 0)
	if frame == null:
		return null
	# Frames have lots of empty space around the character; crop to the top
	# of what's drawn, about as tall as it is wide (the box is near square).
	var used := frame.get_image().get_used_rect()
	used.size.y = mini(used.size.y, used.size.x)
	var cropped := AtlasTexture.new()
	cropped.atlas = frame
	cropped.region = Rect2(used)
	return cropped
