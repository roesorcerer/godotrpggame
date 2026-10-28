extends Node

## Dev-only smoke test for homeschool: studying, the answer key, copying, the
## stats each one moves, the schoolwork chore, and what the table offers.
##   godot --headless --path . res://dev/school_smoke.tscn

const CHAIR_SCENE := "res://props/ranchinside/chair/chair.tscn"
const BAG_SCENE := "res://props/ranchinside/workbook_bag/workbook_bag.tscn"

var _failures: Array[String] = []
var _finished := false            ## set by the last line of _run(); a script error skips it


func _ready() -> void:
	await get_tree().process_frame
	await _run()
	if not _finished:
		_failures.append("_run() did not finish - see the script error above")
	if _failures.is_empty():
		print("SCHOOL SMOKE: PASS")
		get_tree().quit(0)
	else:
		for f in _failures:
			printerr("SCHOOL SMOKE FAIL: ", f)
		get_tree().quit(1)


func _check(cond: bool, label: String) -> void:
	if not cond:
		_failures.append(label)


func _run() -> void:
	_check_subjects()
	_check_study()
	_check_answer_key()
	_check_copy()
	await _check_table_menu()
	_finished = true


func _check_subjects() -> void:
	var ids := School.subjects().map(func(s: SubjectData) -> StringName: return s.id)
	_check(ids.has(&"math") and ids.has(&"english") and ids.has(&"science"), "math, English and science load (%s)" % [ids])
	for subject in School.subjects():
		_check(School.SKILL_NAMES.has(subject.skill), "%s grows a real skill" % subject.id)
	_check(School.grade_letter(&"math") == "C", "everyone starts on a C")
	_check(School.skill_level(&"problem_solving") == 0, "and knowing nothing")


## An hour of real work: XP, a small grade bump, honesty, counts as schoolwork.
func _check_study() -> void:
	GameClock.minutes = 120                       # 8 AM
	GameState.chores_done = []
	var math := School.get_subject(&"math")
	var schoolwork := ChoreSystem.get_chore(School.SCHOOLWORK_CHORE)
	var schoolday := ChoreSystem.is_needed(schoolwork)
	var mood_before := Mom.mood()
	GameState.gas = 50
	var honesty := School.honesty()
	var mins := GameClock.minutes

	_check(School.study(math), "study math")
	_check(School.skill_xp(&"problem_solving") == School.STUDY_XP, "problem solving XP went up")
	_check(School.grade(&"math") == School.START_GRADE + School.STUDY_GRADE, "math grade nudged up")
	_check(School.honesty() == honesty + School.STUDY_HONESTY, "honest work raises honesty")
	_check(GameState.gas == 50 - School.STUDY_GAS, "studying costs Gas")
	_check(GameClock.minutes == mins + School.STUDY_MINUTES, "and an hour")
	if schoolday:
		_check(ChoreSystem.is_done(schoolwork), "it counts as today's schoolwork")
		_check(Mom.mood() == mood_before + schoolwork.mood, "and Mom notices the pages")

	for i in 3:
		School.study(math)
	_check(School.skill_level(&"problem_solving") == 1, "four sessions make level 1")

	GameState.gas = School.STUDY_GAS - 1
	_check(School.study_blocked_reason() == "Too tired", "too tired to study")
	_check(not School.study(math), "so you can't")
	GameState.gas = GameState.gas_max


## The key is only in reach while Mom sleeps, and goes back by morning.
func _check_answer_key() -> void:
	Inventory.remove(School.ANSWER_KEY, 1)
	var bag: WorkbookBag = load(BAG_SCENE).instantiate()
	add_child(bag)

	GameClock.minutes = (14 - GameClock.START_HOUR) * 60    # 2 PM
	_check(not Mom.is_asleep(), "Mom's up at 2 PM")
	_check(bag.get_prompt(null) == "Mom's workbook bag", "awake: it's just her bag")
	bag.interact(null)
	_check(not School.has_answer_key(), "can't take the key while she's awake")

	GameClock.minutes = (Mom.SLEEP_HOUR - GameClock.START_HOUR) * 60 + 30    # 10:30 PM
	_check(Mom.is_asleep(), "asleep at 10:30 PM")
	_check(bag.get_prompt(null) == "Take the answer key", "asleep: the key is in reach")
	var nerve := School.nerve()
	bag.interact(null)
	_check(School.has_answer_key(), "took the key")
	_check(School.nerve() == nerve + School.STEAL_NERVE, "sneaking it builds nerve")
	_check(School.take_key_blocked_reason() == "You already have it", "one key at a time")

	EventBus.day_started.emit(GameClock.day + 1)
	_check(not School.has_answer_key(), "the key is back in her bag by morning")
	bag.queue_free()


## Copying: fast, big grade jump, no learning, costs honesty, builds nerve.
func _check_copy() -> void:
	var english := School.get_subject(&"english")
	GameState.school["copied_today"] = []
	_check(School.copy_blocked_reason(english) == "No answer key", "no key, no copying")

	Inventory.add(School.ANSWER_KEY)
	var xp := School.skill_xp(&"expression")
	var grade := School.grade(&"english")
	var honesty := School.honesty()
	var nerve := School.nerve()
	var mins := GameClock.minutes
	GameState.gas = 50

	_check(School.copy_answers(english), "copy the English answers")
	_check(School.grade(&"english") == grade + School.COPY_GRADE, "English grade jumps")
	_check(School.skill_xp(&"expression") == xp, "but you learned nothing")
	_check(School.honesty() == honesty + School.COPY_HONESTY, "honesty drops")
	_check(School.nerve() == nerve + School.COPY_NERVE, "nerve grows")
	_check(GameState.gas == 50 - School.COPY_GAS, "barely any Gas")
	_check(GameClock.minutes == mins + School.COPY_MINUTES, "and fifteen minutes")
	_check(School.copy_blocked_reason(english) == "Already copied today", "once per subject per day")
	_check(School.copy_blocked_reason(School.get_subject(&"math")) == "", "other subjects still open")

	GameState.begin_new_day(0, false)
	_check(GameState.school["copied_today"].is_empty(), "a new day clears what you copied")
	Inventory.remove(School.ANSWER_KEY, 1)
	GameState.gas = GameState.gas_max


## The kitchen chair lists study, and copying only with the key.
func _check_table_menu() -> void:
	var chair: Node2D = load(CHAIR_SCENE).instantiate()
	add_child(chair)
	await get_tree().process_frame
	var seat: Seat = chair.get_node("Seat")
	_check(seat.allows_study and seat.allows_eating, "kitchen chairs allow eating and study")

	var texts := _texts(seat.options(null))
	_check(texts.has("Study math") and texts.has("Study english") and texts.has("Study science"), "the table offers every subject")
	_check(not texts.has("Copy the math answers"), "no copying without the key")
	_check(texts.has("Stand up"), "and a way to stand up")

	Inventory.add(School.ANSWER_KEY)
	texts = _texts(seat.options(null))
	_check(texts.has("Copy the math answers"), "with the key, copying shows up")
	Inventory.remove(School.ANSWER_KEY, 1)

	seat.allows_study = false
	texts = _texts(seat.options(null))
	_check(not texts.has("Study math"), "a couch (no study) doesn't offer schoolwork")
	chair.queue_free()


func _texts(options: Array) -> Array:
	return options.map(func(o: Dictionary) -> String: return o["text"])
