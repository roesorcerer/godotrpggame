class_name ActionCosts
extends RefCounted

## How many in-game minutes each action spends (GDD 5.1). One place to tune
## the pace of a day. Systems pass these to GameClock.advance():
##   GameClock.advance(ActionCosts.minutes(&"feed_oscar"))
##
## Existing ChoreData.minutes and SeatActivity.minutes still work; new
## systems read from here instead.

const MINUTES := {
	&"water_herbs": 20,
	&"eat": 20,
	&"feed_oscar": 30,
	&"spellbook": 30,
	&"workbench_step": 60,
	&"read": 60,
	&"trampoline": 60,
	&"listen_mom": 60,
	&"clear_pile": 120,
	&"job_shift": 120,
}


## Minutes the action takes. Unknown ids warn and cost 0, so a typo shows up
## in the Output panel instead of silently eating time.
static func minutes(id: StringName) -> int:
	if not MINUTES.has(id):
		push_warning("ActionCosts: no cost for '%s'. Add it to ActionCosts.MINUTES." % id)
		return 0
	return MINUTES[id]
