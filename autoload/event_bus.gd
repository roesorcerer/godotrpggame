extends Node

## Global signal hub. Systems emit and listen here; they never hold
## references to one another. Everything else in the project depends on
## this, so EventBus must be the FIRST autoload registered.

# --- time ------------------------------------------------------------------
signal minute_ticked(day_minutes: int)
signal hour_ticked(hour: int)
signal day_started(day: int)
signal day_ended(day: int, summary: Dictionary)

# --- player resources ------------------------------------------------------
signal gas_changed(current: int, max_value: int)
signal money_changed(amount: int)

# --- house / chores (M2) ---------------------------------------------------
signal room_state_changed(room_id: StringName)
signal chore_completed(chore_id: StringName)

# --- coursework (M2) -------------------------------------------------------
signal coursework_progressed(subject: StringName, amount: float)

# --- family / condition (M5) -----------------------------------------------
signal condition_rolled(state: StringName)   # &"steady" / &"slow" / &"under"

# --- people & story (M4+) --------------------------------------------------
signal relationship_changed(npc_id: StringName, level: int)
signal flag_set(flag: StringName)
signal campaign_changed()

# --- interaction & dialogue (M1) -------------------------------------------
signal interaction_prompt(text: String)      # "" clears the prompt
signal dialogue_started()
signal dialogue_finished()
