class_name QuestData
extends Resource

## One quest or task. Authored as a .tres in data/quests/ - like chores, you
## should never have to open a script to add, change or remove one.
##
## Life of a quest: offered (its day/flag/prerequisite conditions are met) ->
## active (the giver handed it over, or it starts by itself if it has no giver)
## -> done (its goal happened). Rewards are paid on completion.

@export var id: StringName = &""
@export var display_name := ""
@export_multiline var description := ""

@export_group("Giver")
## npc id (see Data.NPC_NAMES) who hands this out when talked to.
## Empty = it starts by itself as soon as it's offered.
@export var giver: StringName = &""
## What the giver says when handing it over.
@export_multiline var offer_line := ""
## Said by the giver when talked to while this quest is still in progress.
## Empty = they use their normal small talk.
@export_multiline var reminder_line := ""
## Said when it's finished by talking to someone (TALK_TO goals).
@export_multiline var done_line := ""

@export_group("When")
## First game day it can be offered (day 1 is the first morning).
@export_range(1, 84) var first_day := 1
## Last day it can be offered or finished. 0 = no end.
@export_range(0, 84) var last_day := 0
## Days of the week it's offered, 0 = Mon ... 6 = Sun. Empty = any day.
@export var weekdays: Array[int] = []
## Story gating: only offered once this GameState flag is set.
@export var requires_flag: StringName = &""
## Only offered once this quest is done.
@export var requires_quest: StringName = &""
## Dropped at bedtime if not finished (it can be offered again on a later day).
@export var daily := false

@export_group("Goal")
@export var goal: Enum.QuestGoal = Enum.QuestGoal.TALK_TO
## TALK_TO: an npc id.  VISIT: a place id (scene file name, e.g. alder_grove).
## FLAG: a GameState flag.
@export var goal_target: StringName = &""

@export_group("Reward")
@export var reward_money := 0
## Change to Mom's mood (can be negative).
@export_range(-20, 20) var reward_mood := 0
## Set when done - use it to unlock later quests or chores.
@export var reward_flag: StringName = &""


## Short "what to do" line for the HUD.
func goal_text() -> String:
	match goal:
		Enum.QuestGoal.TALK_TO:
			return "Talk to %s" % Data.NPC_NAMES.get(goal_target, String(goal_target))
		Enum.QuestGoal.VISIT:
			return "Go to %s" % Data.PLACE_NAMES.get(goal_target, String(goal_target))
	return description
