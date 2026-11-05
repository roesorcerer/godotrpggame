extends Node

## Loads every QuestData in data/quests/ and runs quests and tasks. Adding a
## quest is a .tres file, never a code change.
##
## Progress lives in GameState.quests (id -> "active" / "done") so it saves
## and survives sleep. Quests finish by listening on the EventBus: talking to
## someone, arriving somewhere, or a story flag being set.

const QUEST_DIR := "res://data/quests"
const ACTIVE := "active"
const DONE := "done"

var _catalog: Dictionary = {}          ## StringName -> QuestData


func _ready() -> void:
	_load_catalog()
	EventBus.day_started.connect(func(_d): _refresh())
	EventBus.place_visited.connect(func(place): _progress(Enum.QuestGoal.VISIT, place))
	EventBus.flag_set.connect(func(flag): _progress(Enum.QuestGoal.FLAG, flag))
	_refresh.call_deferred()


func _load_catalog() -> void:
	_catalog.clear()
	var dir := DirAccess.open(QUEST_DIR)
	if dir == null:
		push_warning("QuestSystem: no %s directory." % QUEST_DIR)
		return
	for file in dir.get_files():
		# Exported builds rename .tres to .remap; strip either.
		var p_name := file.trim_suffix(".remap")
		if not p_name.ends_with(".tres"):
			continue
		var quest := load("%s/%s" % [QUEST_DIR, p_name]) as QuestData
		if quest == null:
			push_warning("QuestSystem: %s is not a QuestData." % p_name)
			continue
		if quest.id == &"":
			push_warning("QuestSystem: %s has no id." % p_name)
			continue
		_catalog[quest.id] = quest


func get_quest(quest_id: StringName) -> QuestData:
	return _catalog.get(quest_id)

func all() -> Array:
	return _catalog.values()


## --- status ---------------------------------------------------------------

func is_active(quest: QuestData) -> bool:
	return GameState.quests.get(String(quest.id)) == ACTIVE

func is_done(quest: QuestData) -> bool:
	return GameState.quests.get(String(quest.id)) == DONE

## Not started yet, and today meets all of its conditions.
func is_offered(quest: QuestData) -> bool:
	if GameState.quests.has(String(quest.id)):
		return false
	if GameClock.day < quest.first_day or (quest.last_day > 0 and GameClock.day > quest.last_day):
		return false
	if not quest.weekdays.is_empty() and not quest.weekdays.has(GameClock.weekday()):
		return false
	if quest.requires_flag != &"" and not GameState.has_flag(quest.requires_flag):
		return false
	if quest.requires_quest != &"":
		var before := get_quest(quest.requires_quest)
		if before == null or not is_done(before):
			return false
	return true

func active() -> Array:
	return _catalog.values().filter(is_active)

func offers_from(npc_id: StringName) -> Array:
	return _catalog.values().filter(func(q): return q.giver == npc_id and is_offered(q))

## Everyone with something to hand out today, for "Talk to Mom" hints.
func givers_with_offers() -> Array[StringName]:
	var givers: Array[StringName] = []
	for quest in _catalog.values():
		if quest.giver != &"" and is_offered(quest) and not givers.has(quest.giver):
			givers.append(quest.giver)
	return givers


## --- talking --------------------------------------------------------------

## The player talked to npc_id. Finishes TALK_TO quests aimed at them, then
## hands over one quest they're offering; failing both, reminds the player of
## a quest they gave out that's still in progress. Returns what they say
## ("" = nothing quest-related, so the NPC uses its own small talk).
func talk_to(npc_id: StringName) -> String:
	var lines: Array[String] = []
	for quest in _progress(Enum.QuestGoal.TALK_TO, npc_id):
		if quest.done_line != "":
			lines.append(quest.done_line)
	var offers := offers_from(npc_id)
	if not offers.is_empty():
		var quest: QuestData = offers[0]
		start(quest)
		if quest.offer_line != "":
			lines.append(quest.offer_line)
	if lines.is_empty():
		for quest in active():
			if quest.giver == npc_id and quest.reminder_line != "":
				lines.append(quest.reminder_line)
				break
	EventBus.npc_talked.emit(npc_id)
	return "\n".join(lines)


## --- changing state ---------------------------------------------------------

func start(quest: QuestData) -> void:
	if not is_offered(quest):
		return
	GameState.quests[String(quest.id)] = ACTIVE
	EventBus.quest_started.emit(quest.id)
	EventBus.quests_changed.emit()
	# A FLAG goal may already be met.
	if quest.goal == Enum.QuestGoal.FLAG and GameState.has_flag(quest.goal_target):
		complete(quest)


func complete(quest: QuestData) -> void:
	if not is_active(quest):
		return
	GameState.quests[String(quest.id)] = DONE
	if quest.reward_money != 0:
		GameState.add_money(quest.reward_money)
	if quest.reward_mood != 0:
		Mom.change(quest.reward_mood)
	GameState.day_log.append({"kind": "quest", "id": quest.id, "name": quest.display_name})
	EventBus.quest_completed.emit(quest.id)
	EventBus.quests_changed.emit()
	# Last: the flag may unlock (or finish) other quests.
	if quest.reward_flag != &"":
		GameState.set_flag(quest.reward_flag)
	_refresh()


## Completes active quests whose goal matches; returns the ones it finished.
func _progress(goal: Enum.QuestGoal, target: StringName) -> Array:
	var finished := active().filter(func(q): return q.goal == goal and q.goal_target == target)
	for quest in finished:
		complete(quest)
	return finished


## Starts giverless quests that became available (new day, flag, quest done).
func _refresh() -> void:
	for quest in _catalog.values():
		if quest.giver == &"" and is_offered(quest):
			start(quest)
	EventBus.quests_changed.emit()


## --- bedtime --------------------------------------------------------------

## Called by GameClock.end_day(). Drops unfinished daily tasks and writes what
## got done into the day summary.
func close_day(summary: Dictionary) -> void:
	for quest in active():
		if quest.daily or (quest.last_day > 0 and GameClock.day >= quest.last_day):
			GameState.quests.erase(String(quest.id))
	summary["quests_done"] = GameState.day_log \
		.filter(func(e): return e.get("kind") == "quest") \
		.map(func(e): return e.get("name"))
