extends TextureRect

## The backpack menu (I / Tab, Esc or the X to close), drawn by
## assets/UI/backpack_menu.png. The art already draws the slots, tabs and
## buttons; this places invisible controls on top of them. Coordinates below
## are pixels in the cropped art (see the AtlasTexture region in hud.tscn).
##
## Slots past GameState.backpack_size are shaded as locked until an upgrade.
## Drag items between slots, onto the trash can to throw them away; hover to
## read one. Time stops while it's open, like Stardew.

signal toggled(open: bool)
signal tab_selected(index: int)

const SLOT_SCENE := preload("res://scenes/ui/inventory_slot.tscn")

## Top-left of each slot in the art (one per column / row), 22x22 each.
const SLOT_X := [19, 44, 70, 96, 122, 149, 176, 203, 230]
const SLOT_Y := [44, 71, 100]
const SLOT_SIZE := Vector2(22, 22)

## Tabs along the top, left to right. Only the backpack (0) has a page so far.
const TAB_NAMES := ["Backpack", "Skills", "Relationships", "Collections", "Phone"]
const INVENTORY_TAB := 0

@onready var _info: Label = $Info
@onready var _money: Label = $Money
@onready var _portrait: TextureRect = $Portrait

var _slots: Array[InventorySlot] = []


func _ready() -> void:
	visible = false
	for i in Data.BACKPACK_MAX_SIZE:
		var slot: InventorySlot = SLOT_SCENE.instantiate()
		slot.index = i
		slot.base_style = &"BackpackSlot"
		slot.position = Vector2(SLOT_X[i % SLOT_X.size()], SLOT_Y[i / SLOT_X.size()])
		slot.custom_minimum_size = SLOT_SIZE
		slot.size = SLOT_SIZE
		slot.hovered.connect(_show_info)
		add_child(slot)
		_slots.append(slot)

	$CloseButton.pressed.connect(close)
	$OrganizeButton.pressed.connect(Inventory.sort)
	for i in TAB_NAMES.size():
		var tab: Button = get_node("Tabs/Tab%d" % i)
		tab.tooltip_text = TAB_NAMES[i]
		tab.pressed.connect(_on_tab_pressed.bind(i))

	EventBus.inventory_changed.connect(_refresh)
	EventBus.money_changed.connect(func(_m): _refresh_money())
	_refresh()


func _refresh() -> void:
	for slot in _slots:
		slot.locked = slot.index >= Inventory.size()
		slot.refresh()
	_refresh_money()


func _refresh_money() -> void:
	_money.text = "$%d" % GameState.money


func _show_info(index: int) -> void:
	var item := Inventory.item_at(index)
	if item != null:
		_info.text = "%s\n%s" % [item.display_name, item.description]
	elif index >= Inventory.size():
		_info.text = "Locked - get a bigger backpack."
	else:
		_info.text = ""


func _on_tab_pressed(index: int) -> void:
	tab_selected.emit(index)
	if index != INVENTORY_TAB:
		_info.text = "%s - coming soon." % TAB_NAMES[index]


## The player as they look right now, for the portrait box.
func _refresh_portrait() -> void:
	var player := SceneRouter.get_player()
	var sprite := player.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D if player else null
	if sprite == null:
		return
	# Walk frames have lots of empty space around the character; crop to it.
	var frame := sprite.sprite_frames.get_frame_texture(&"idle_down", 0)
	var used := frame.get_image().get_used_rect()
	var cropped := AtlasTexture.new()
	cropped.atlas = frame
	cropped.region = Rect2(used)
	_portrait.texture = cropped


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		get_viewport().set_input_as_handled()
		if visible:
			close()
		elif not GameClock.is_paused():   # not during fades, the day summary, ...
			open()
	elif visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func open() -> void:
	_refresh()
	_refresh_portrait()
	_info.text = ""
	visible = true
	GameClock.request_pause()
	toggled.emit(true)


func close() -> void:
	if not visible:
		return
	visible = false
	GameClock.release_pause()
	toggled.emit(false)
