extends Node

## Homeschool coursework. The obligation that only moves when you move it,
## which is exactly why it slides. See §05.
##
## Yield scales with the hour and with the Gas you have left when you sit down,
## so a day spent hauling Bruce's junk teaches you badly. Nothing in the UI
## says so.

const COURSEWORK_DIR := "res://data/coursework"

## Progress needed to finish one assignment.
const UNITS_PER_ASSIGNMENT := 3.0

## Concentration multipliers.
const QUIET_HOURS_BONUS := 1.15     ## 7-9 AM, rested
const SAG_PENALTY := 0.66           ## 12-3 PM
const LOW_GAS_PENALTY := 0.5        ## below LOW_GAS_THRESHOLD, any hour
const LOW_GAS_THRESHOLD := 30
const RESTED_GAS := 70
const TAUGHT_BONUS := 2.0           ## Doris teaching, Steady mornings only

var _catalog: Dictionary = {}        ## StringName -> CourseworkData


func _ready() -> void:
	_load_catalog()


func _load_catalog() -> void:
	_catalog.clear()
	var dir := DirAccess.open(COURSEWORK_DIR)
	if dir == null:
		push_warning("CourseworkSystem: no %s directory." % COURSEWORK_DIR)
		return
	for file in dir.get_files():
		var name := file.trim_suffix(".remap")
		if not name.ends_with(".tres"):
			continue
		var work := load("%s/%s" % [COURSEWORK_DIR, name]) as CourseworkData
		if work == null or work.id == &"":
			continue
		_catalog[work.id] = work


func count() -> int:
	return _catalog.size()

func all() -> Array:
	return _catalog.values()


## --- per-subject progress (stored in GameState.coursework) -----------------

func subject_state(subject: StringName) -> Dictionary:
	if not GameState.coursework.has(subject):
		GameState.coursework[subject] = {"progress": 0.0, "done": []}
	return GameState.coursework[subject]

func progress(subject: StringName) -> float:
	return float(subject_state(subject).get("progress", 0.0))

func completed(subject: StringName) -> Array:
	return subject_state(subject).get("done", [])

func is_done(work: CourseworkData) -> bool:
	return completed(work.subject).has(String(work.id))


## The next assignment in a subject, or null when the packet is finished.
func next_assignment(subject: StringName) -> CourseworkData:
	var pending: Array = []
	for work in _catalog.values():
		if work.subject == subject and not is_done(work):
			pending.append(work)
	if pending.is_empty():
		return null
	pending.sort_custom(func(a, b): return a.sequence < b.sequence)
	return pending[0]


## How many assignments are outstanding across every subject - the stack on the
## kitchen table.
func backlog() -> int:
	var n := 0
	for work in _catalog.values():
		if not is_done(work):
			n += 1
	return n


## --- concentration --------------------------------------------------------

## The multiplier applied to work done right now. Also drives the UI wording,
## so keep the two in step.
func concentration() -> float:
	var mult := 1.0

	if GameState.doris.get("today", &"steady") == &"steady" and GameState.has_flag(&"doris_teaching"):
		mult = TAUGHT_BONUS
	elif GameClock.is_quiet_hours() and GameState.gas >= RESTED_GAS:
		mult = QUIET_HOURS_BONUS
	elif GameClock.clock_hour() >= 12 and GameClock.clock_hour() < 15:
		mult = SAG_PENALTY

	if GameState.gas < LOW_GAS_THRESHOLD:
		mult *= LOW_GAS_PENALTY

	return mult


func concentration_label() -> String:
	var c := concentration()
	if c >= 1.9:
		return "She's helping"
	if c >= 1.1:
		return "Sharp"
	if c >= 0.95:
		return "Fine"
	if c >= 0.6:
		return "Sluggish"
	return "Not taking it in"


## --- doing the work -------------------------------------------------------

func blocked_reason(work: CourseworkData) -> String:
	if work == null:
		return "Nothing left in the packet"
	if GameState.gas < work.gas_cost:
		return "Too tired"
	return ""


## One sitting. Returns the progress actually earned (0.0 if nothing happened).
func study(work: CourseworkData) -> float:
	if work == null or blocked_reason(work) != "":
		return 0.0
	if not GameState.spend_gas(work.gas_cost):
		return 0.0

	var earned := work.work_units * concentration()
	var state := subject_state(work.subject)
	state["progress"] = float(state["progress"]) + earned

	var finished := false
	if float(state["progress"]) >= UNITS_PER_ASSIGNMENT:
		state["progress"] = float(state["progress"]) - UNITS_PER_ASSIGNMENT
		state["done"].append(String(work.id))
		finished = true

	GameClock.advance(work.minutes)
	GameState.day_log.append({
		"kind": "coursework",
		"id": work.id,
		"name": work.title,
		"earned": earned,
		"finished": finished,
	})
	EventBus.coursework_progressed.emit(work.subject, earned)
	return earned
