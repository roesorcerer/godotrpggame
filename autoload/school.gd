extends Node

## Homeschool: subjects, skills, grades, honesty and nerve. The state lives in
## GameState.school; this node is the rules. Studying happens at a Seat that
## allows it (the kitchen table); the answer key comes from Mom's workbook bag.
##
##   skills   - what you actually know. Only honest study grows them; they
##              never drop. Levels 0-10.
##   grades   - what the workbook shows Mom, 0-100 per subject. Studying
##              nudges them up; copying the answer key pushes them up fast.
##   honesty  - 0-100. Studying for real raises it a little; copying costs.
##   nerve    - 0-100. Sneaking the key and copying build it. Never drops.
##
## Studying or copying also counts as today's "Do schoolwork" chore - as far
## as Mom can tell, the pages got filled in either way.

const SUBJECT_DIR := "res://data/subjects"
const SCHOOLWORK_CHORE := &"schoolwork"
const ANSWER_KEY := &"answer_key"

const SKILL_NAMES := {
	&"problem_solving": "Problem Solving",
	&"expression": "Expression",
	&"curiosity": "Curiosity",
}
const XP_PER_LEVEL := 100
const MAX_LEVEL := 10

const START_GRADE := 70

## Honest study.
const STUDY_MINUTES := 60
const STUDY_GAS := 10
const STUDY_XP := 25
const STUDY_GRADE := 3
const STUDY_HONESTY := 1

## Copying from the answer key.
const COPY_MINUTES := 15
const COPY_GAS := 2
const COPY_GRADE := 10
const COPY_HONESTY := -5
const COPY_NERVE := 2

## Sneaking the key out of Mom's bag.
const STEAL_NERVE := 3

var _subjects: Array[SubjectData] = []


func _ready() -> void:
	_load_subjects()
	# The key goes back in her bag before she wakes - you don't keep it.
	EventBus.day_started.connect(func(_day: int) -> void:
		Inventory.remove(ANSWER_KEY, Inventory.count_of(ANSWER_KEY)))


func _load_subjects() -> void:
	_subjects.clear()
	var dir := DirAccess.open(SUBJECT_DIR)
	if dir == null:
		push_warning("School: no %s directory." % SUBJECT_DIR)
		return
	for file in dir.get_files():
		# Exported builds rename .tres to .remap; strip either.
		var name := file.trim_suffix(".remap")
		if not name.ends_with(".tres"):
			continue
		var subject := load("%s/%s" % [SUBJECT_DIR, name]) as SubjectData
		if subject == null or subject.id == &"":
			push_warning("School: %s is not a SubjectData with an id." % name)
			continue
		if not SKILL_NAMES.has(subject.skill):
			push_warning("School: %s grows '%s', which isn't in SKILL_NAMES." % [name, subject.skill])
		_subjects.append(subject)
	_subjects.sort_custom(func(a: SubjectData, b: SubjectData) -> bool:
		return a.display_name < b.display_name)


## --- reading --------------------------------------------------------------

func subjects() -> Array[SubjectData]:
	return _subjects


func get_subject(subject_id: StringName) -> SubjectData:
	for subject in _subjects:
		if subject.id == subject_id:
			return subject
	return null


func skill_xp(skill: StringName) -> int:
	return int(GameState.school["skills"].get(skill, 0))


func skill_level(skill: StringName) -> int:
	return mini(skill_xp(skill) / XP_PER_LEVEL, MAX_LEVEL)


func grade(subject_id: StringName) -> int:
	return int(GameState.school["grades"].get(subject_id, START_GRADE))


func grade_letter(subject_id: StringName) -> String:
	var g := grade(subject_id)
	if g >= 90: return "A"
	if g >= 80: return "B"
	if g >= 70: return "C"
	if g >= 60: return "D"
	return "F"


func honesty() -> int:
	return int(GameState.school.get("honesty", 60))


func nerve() -> int:
	return int(GameState.school.get("nerve", 0))


## --- studying -------------------------------------------------------------

## "" if the player can study right now, otherwise why not.
func study_blocked_reason() -> String:
	if GameState.gas < STUDY_GAS:
		return "Too tired"
	return ""


## An hour of real work: skill XP, a small grade bump, a little honesty.
func study(subject: SubjectData) -> bool:
	if study_blocked_reason() != "" or not GameState.spend_gas(STUDY_GAS):
		return false
	var level_up := add_xp(subject.skill, STUDY_XP)
	_change_grade(subject.id, STUDY_GRADE)
	_change(&"honesty", STUDY_HONESTY)
	_finish_schoolwork("study", subject)
	EventBus.notice.emit(subject.study_line + level_up)
	# Last: running the clock out ends the day.
	GameClock.advance(STUDY_MINUTES)
	return true


## Practice outside schoolwork (reading on the couch) grows a skill too.
## Returns a "\nExpression is now level 2." line on a level-up, else "".
func add_xp(skill: StringName, amount: int) -> String:
	if amount <= 0:
		return ""
	var before := skill_level(skill)
	GameState.school["skills"][skill] = mini(skill_xp(skill) + amount, XP_PER_LEVEL * MAX_LEVEL)
	EventBus.stats_changed.emit()
	if skill_level(skill) > before:
		return "\n%s is now level %d." % [SKILL_NAMES.get(skill, String(skill)), skill_level(skill)]
	return ""


## --- cheating -------------------------------------------------------------

func has_answer_key() -> bool:
	return Inventory.has(ANSWER_KEY)


## "" if the key can be taken from Mom's bag now, otherwise why not.
func take_key_blocked_reason() -> String:
	if has_answer_key():
		return "You already have it"
	if not Mom.is_asleep():
		return "Not while she's awake"
	return ""


func take_answer_key() -> bool:
	if take_key_blocked_reason() != "" or Inventory.add(ANSWER_KEY) > 0:
		return false
	_change(&"nerve", STEAL_NERVE)
	return true


## "" if this subject's answers can be copied now, otherwise why not.
func copy_blocked_reason(subject: SubjectData) -> String:
	if not has_answer_key():
		return "No answer key"
	if GameState.school["copied_today"].has(String(subject.id)):
		return "Already copied today"
	if GameState.gas < COPY_GAS:
		return "Too tired"
	return ""


## Fifteen minutes with the key: a big grade jump, no learning, and it costs
## honesty - but it builds nerve.
func copy_answers(subject: SubjectData) -> bool:
	if copy_blocked_reason(subject) != "" or not GameState.spend_gas(COPY_GAS):
		return false
	GameState.school["copied_today"].append(String(subject.id))
	_change_grade(subject.id, COPY_GRADE)
	_change(&"honesty", COPY_HONESTY)
	_change(&"nerve", COPY_NERVE)
	_finish_schoolwork("copy", subject)
	EventBus.notice.emit("You copy the %s answers in your own handwriting, and get a couple wrong on purpose." % subject.display_name.to_lower())
	GameClock.advance(COPY_MINUTES)
	return true


## --- helpers --------------------------------------------------------------

func _change_grade(subject_id: StringName, delta: int) -> void:
	GameState.school["grades"][subject_id] = clampi(grade(subject_id) + delta, 0, 100)
	EventBus.stats_changed.emit()


func _change(trait_id: StringName, delta: int) -> void:
	GameState.school[String(trait_id)] = clampi(int(GameState.school.get(String(trait_id), 0)) + delta, 0, 100)
	EventBus.stats_changed.emit()


## Either way, the workbook pages are filled in: it counts as schoolwork.
func _finish_schoolwork(how: String, subject: SubjectData) -> void:
	GameState.day_log.append({"kind": how, "id": subject.id, "name": subject.display_name})
	ChoreSystem.credit(ChoreSystem.get_chore(SCHOOLWORK_CHORE))
