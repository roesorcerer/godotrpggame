class_name ChoiceMenu
extends CanvasLayer

## A small "what do you want to do?" list. Each option is a Dictionary:
##   text      - the button label
##   hint      - shown under the list when the option is focused (optional)
##   disabled  - greyed out and can't be picked (optional); put why in hint
##   action    - Callable run after the menu closes
## Esc closes without choosing. Time stops while it's open; the menu frees
## itself when it closes.
##
##   var menu: ChoiceMenu = preload("res://ui/choice_menu/choice_menu.tscn").instantiate()
##   get_tree().root.add_child(menu)
##   menu.open("At the table", [{"text": "Read", "action": read}])

signal closed()

@onready var _title: Label = %Title
@onready var _list: VBoxContainer = %List
@onready var _hint: Label = %Hint
@onready var _close_label: Label = %CloseLabel

var _is_open := false


## cancel_text: what Esc means here, e.g. "Just sit".
func open(title: String, options: Array, cancel_text := "Close") -> void:
	_is_open = true
	GameClock.request_pause()
	_title.text = title
	_close_label.text = "[Esc] %s" % cancel_text
	for option in options:
		_list.add_child(_make_button(option))
	for button in _list.get_children():
		if not (button as Button).disabled:
			button.grab_focus.call_deferred()
			break


## Pick an option by its text, as if clicked. For tests and scripted scenes.
func choose(text: String) -> bool:
	for button in _list.get_children():
		if button.text == text and not button.disabled:
			button.pressed.emit()
			return true
	return false


func option_texts() -> Array[String]:
	var texts: Array[String] = []
	for button in _list.get_children():
		texts.append(button.text)
	return texts


func close() -> void:
	if not _is_open:
		return
	_is_open = false
	GameClock.release_pause()
	closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("inventory"):
		get_viewport().set_input_as_handled()
		close()


func _make_button(option: Dictionary) -> Button:
	var button := Button.new()
	button.text = option.get("text", "")
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 9)
	button.disabled = option.get("disabled", false)
	var hint: String = option.get("hint", "")
	button.focus_entered.connect(func() -> void: _hint.text = hint)
	button.mouse_entered.connect(func() -> void: _hint.text = hint)
	var action: Callable = option.get("action", Callable())
	button.pressed.connect(func() -> void:
		close()
		if action.is_valid():
			action.call())
	return button
