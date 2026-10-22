extends Node

const PLAYER_SKINS = {}

const TILE_SIZE = 16

const PLANT_DATA = {}

const MACHINE_UPGRADE_COST = {}

const HOUSE_COST = {}

const STYLE_UPGRADES = {}


const TOOL_STATE_ANIMATIONS = {
	Enum.Tool.SHOVEL: 'Shovel',
	Enum.Tool.AXE: 'Axe',
	Enum.Tool.WATER: 'Water',
	Enum.Tool.SEED: 'Seed',
}

# Atlas source id of dirt.png inside dirt_set.tres.
const SOIL_SOURCE = 2

# dirt.png is a corner-based (dual-grid) sheet: each tile is picked by which
# of its 4 corners sit on dug cells. Bits: TL=1, TR=2, BL=4, BR=8.
const SOIL_TILES = {
	1: Vector2i(2, 2), 2: Vector2i(0, 2), 3: Vector2i(1, 2),
	4: Vector2i(2, 0), 5: Vector2i(2, 1), 7: Vector2i(3, 0),
	8: Vector2i(0, 0), 10: Vector2i(0, 1), 11: Vector2i(4, 0),
	12: Vector2i(1, 0), 13: Vector2i(3, 1), 14: Vector2i(4, 1),
	15: Vector2i(1, 1),
	# No art for diagonal-only pairs; join them with solid dirt.
	6: Vector2i(4, 2), 9: Vector2i(4, 2),
}

## Display names for npc ids used by NpcTalk and QuestData.giver / goal_target.
const NPC_NAMES = {
	&"mom": "Mom",
	&"bruce": "Bruce",
	&"oscar": "Oscar",
}

## Display names for place ids (a scene's file name, e.g. pine_grove.tscn ->
## &"pine_grove") used by VISIT quests.
const PLACE_NAMES = {
	&"ranch": "the ranch",
	&"ranch_interior": "the house",
	&"pine_grove": "Pine Grove",
}

## Backpack: the first HOTBAR_SIZE slots are the hotbar along the bottom of the
## screen. The player starts with BACKPACK_START_SIZE slots; upgrades raise
## GameState.backpack_size up to BACKPACK_MAX_SIZE.
## These match ui/sprites/backpack_menu.png: 9 slots per row, 3 rows.
const HOTBAR_SIZE = 9
const BACKPACK_START_SIZE = 18
const BACKPACK_MAX_SIZE = 27

## Items a new game starts with, filled into the hotbar left to right. The
## tools are ItemData with category TOOL; holding one sets the player's tool.
const STARTING_ITEMS = [&"axe", &"shovel", &"watering_can", &"seed_bag"]

## Physics layer bits, matching the names in Project Settings > Layer Names > 2D Physics.
const PHYSICS_TERRAIN = 1        ## layer 1: tiles, buildings, furniture
const PHYSICS_PLAYER = 2         ## layer 2: the player's body
const PHYSICS_OBJECT = 4         ## layer 3: E-interactables (Interactable.LAYER)
const PHYSICS_CHARACTERS = 8     ## layer 4: NPCs
