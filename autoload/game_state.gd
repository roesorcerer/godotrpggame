extends Node

## Everything that survives sleep lives here and nowhere else.
## Scenes READ from this on _ready; they never store gameplay state themselves.
## One dictionary in, one dictionary out - that is the whole save format (M3).

const GAS_BASE_MAX := 100
const GAS_CAP_PASSED_OUT := 70         ## up past midnight
const GAS_PENALTY_NO_DINNER := 20
const GAS_BONUS_BREAKFAST := 10        ## Mom made breakfast (she's in a good mood)

var money := 0
var gas := GAS_BASE_MAX
var gas_max := GAS_BASE_MAX

var flags := {}          ## StringName -> bool
## Per-object world state that isn't a yes/no flag, e.g. a fireplace's
## OFF/WOOD/LIT. Key is the object's state_key; value is any plain Variant.
var props := {}
var npcs := {}           ## npc_id    -> {level:int, met:bool}  (quest progress is in `quests`)
## Backpack slots: each is {} (empty) or {"id": String, "count": int}. See Inventory.
var inventory: Array = []
var backpack_size := 18                ## Data.BACKPACK_START_SIZE; upgrades raise it
## The kitchen fridge: item id -> count. Only Cooking changes it.
var fridge: Dictionary = Data.STARTING_FRIDGE.duplicate()

## Mom. `mood` is 0-100 (see the Mom autoload); `mood_at_dawn` is where it
## stood this morning, for the day-end summary.
var doris := {
	"mood": 60,
	"mood_at_dawn": 60,
}

var campaign := {
	"fund": 0,
	"commitments": [],
	"events_run": [],
}


## Ids of the chores done today. Cleared each morning.
var chores_done: Array = []

## Ids of the once-a-day seat activities (meals) done today. Cleared each morning.
var meals_today: Array = []

## Quest progress: quest id -> "active" / "done". Kept across days (see QuestSystem).
var quests := {}

## What happened today. Cleared each morning, read by the day-end summary.
var day_log: Array = []

## Set true by the dinner beat only when the player actually skips it.
## Reset every morning, so "nobody implemented dinner yet" costs nothing.
var skipped_dinner := false


## --- resources -------------------------------------------------------------

func spend_gas(amount: int) -> bool:
	if amount <= 0:
		return true
	if gas < amount:
		return false
	gas -= amount
	EventBus.gas_changed.emit(gas, gas_max)
	return true

func restore_gas(amount: int) -> void:
	gas = mini(gas + amount, gas_max)
	EventBus.gas_changed.emit(gas, gas_max)

func add_money(amount: int) -> void:
	money += amount
	EventBus.money_changed.emit(money)

func set_flag(flag: StringName, value := true) -> void:
	flags[flag] = value
	EventBus.flag_set.emit(flag)

func has_flag(flag: StringName) -> bool:
	return flags.get(flag, false)


## --- the overnight roll ----------------------------------------------------

## Called by GameClock.end_day(). Works out tomorrow's Gas ceiling from how
## last night actually went. See §06 of the design bible.
func begin_new_day(slept_at_minutes: int, passed_out: bool) -> void:
	var cap := GAS_BASE_MAX

	if passed_out or slept_at_minutes >= (GameClock.BEDTIME_HOUR - GameClock.START_HOUR) * 60:
		cap = GAS_CAP_PASSED_OUT
	if skipped_dinner:
		cap -= GAS_PENALTY_NO_DINNER

	# Mom makes breakfast when she's happy with you. It lifts the ceiling
	# rather than topping you up, so it's worth something on a good day too.
	if Mom.makes_breakfast():
		cap += GAS_BONUS_BREAKFAST

	gas_max = maxi(cap, 30)
	gas = gas_max

	skipped_dinner = false
	day_log = []
	chores_done = []
	meals_today = []
	doris["mood_at_dawn"] = Mom.mood()
	EventBus.gas_changed.emit(gas, gas_max)
	EventBus.money_changed.emit(money)


## --- save blob (M3 consumes these) -----------------------------------------

func to_dict() -> Dictionary:
	return {
		"version": 5,
		"day": GameClock.day,
		"minutes": GameClock.minutes,
		"money": money,
		"gas": gas,
		"gas_max": gas_max,
		"flags": flags,
		"props": props,
		"npcs": npcs,
		"inventory": inventory,
		"backpack_size": backpack_size,
		"fridge": fridge,
		"doris": doris,
		"campaign": campaign,
		"chores_done": chores_done,
		"meals_today": meals_today,
		"quests": quests,
		"day_log": day_log,
		"skipped_dinner": skipped_dinner,
	}

func from_dict(data: Dictionary) -> void:
	GameClock.day = int(data.get("day", 1))
	GameClock.minutes = int(data.get("minutes", 0))
	money = int(data.get("money", 0))
	gas = int(data.get("gas", GAS_BASE_MAX))
	gas_max = int(data.get("gas_max", GAS_BASE_MAX))
	flags = data.get("flags", {})
	props = data.get("props", {})
	npcs = data.get("npcs", {})
	inventory = data.get("inventory", [])
	backpack_size = int(data.get("backpack_size", backpack_size))
	fridge = data.get("fridge", Data.STARTING_FRIDGE.duplicate())
	doris = data.get("doris", doris)
	campaign = data.get("campaign", campaign)
	chores_done = data.get("chores_done", [])
	meals_today = data.get("meals_today", [])
	quests = data.get("quests", {})
	day_log = data.get("day_log", [])
	skipped_dinner = bool(data.get("skipped_dinner", false))

	EventBus.minute_ticked.emit(GameClock.minutes)
	EventBus.gas_changed.emit(gas, gas_max)
	EventBus.money_changed.emit(money)
	EventBus.mom_mood_changed.emit(int(doris.get("mood", 60)))
	EventBus.chores_changed.emit()
	EventBus.quests_changed.emit()
	EventBus.inventory_changed.emit()
	EventBus.fridge_changed.emit()
	EventBus.stats_changed.emit()
