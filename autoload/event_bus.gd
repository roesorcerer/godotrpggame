extends Node

## Global signal hub. Systems emit and listen here; they never hold
## references to one another. Everything else in the project depends on
## this, so EventBus must be the FIRST autoload registered.

# --- time ------------------------------------------------------------------
signal minute_ticked(day_minutes: int)
signal hour_ticked(hour: int)
signal day_started(day: int)
signal day_ended(day: int, summary: Dictionary)
signal time_advanced(minutes: int)                 # minutes just spent by GameClock.advance()

# --- player resources ------------------------------------------------------
signal gas_changed(current: int, max_value: int)
signal money_changed(amount: int)

# --- house / chores (M2) ---------------------------------------------------
signal room_entered(room_id: StringName)      # player walked into a RoomZone
signal chore_completed(chore_id: StringName)
signal chores_changed()                       # today's list moved: done, new day, load
signal mom_mood_changed(mood: int)

# --- family / condition (M5) -----------------------------------------------
signal condition_rolled(state: StringName)   # &"steady" / &"slow" / &"under"

# --- people & story (M4+) --------------------------------------------------
signal relationship_changed(npc_id: StringName, level: int)
signal npc_talked(npc_id: StringName)          # player talked to someone
signal place_visited(place_id: StringName)     # player arrived in a scene
signal npc_said(speaker: String, text: String, portrait: Texture2D) # an NPC talking: the dialogue box with their portrait
signal notice(text: String)                       # anything else to tell the player (your thoughts, results): the notice panel
signal quest_started(quest_id: StringName)
signal quest_completed(quest_id: StringName)
signal quests_changed()                         # offered/active/done moved

# --- inventory -------------------------------------------------------------
signal inventory_changed()                      # any slot changed
signal hotbar_selected(index: int)
signal item_added(item_id: StringName, count: int)
signal stats_changed()                          # a player stat moved (unused until A-11)
signal fridge_changed()                         # something went in or out of the fridge
signal flag_set(flag: StringName)
signal campaign_changed()

# --- interaction & dialogue (M1) -------------------------------------------
signal interaction_prompt(text: String)      # "" clears the prompt
signal dialogue_started()
signal dialogue_finished()
