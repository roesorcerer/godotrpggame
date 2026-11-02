# Pine Grove (Godot project)

A narrative life sim. A teen spends one summer (2006) on a run-down ranch in Northern California with an alcoholic mom, a hostile stepdad (Bruce) and a younger brother (Oscar). The teen builds a self out of four inner voices and the ghosts of a dying resort, Pine Grove. Solo developer, about 10–20 hours a week.

## Where the design lives

- **Source of truth:** the online GDD, https://claude.ai/artifact/3mhR7qR5CS8Fd46fRaD7gm (three tabs: the GDD, the summer calendar and the demo build list).
- **Copy in the repo:** `docs/design/` (`gdd.md`, `summer-calendar.md`, `demo-build-list.md`). It is a snapshot: when the online GDD changes, re-export it and commit it. If the two disagree, the online GDD wins.
- **Tasks:** GitHub issues labelled `phase-a`. A-01 to A-50 are sub-issues of the epics #1–#7. Each issue lists the files to create or change and has a **Done when** checklist. Where an issue and GDD 10.1 differ, follow the issue, because it's newer (e.g. junk piles are an Interactable, and the tool-on-tile code is removed in A-41).

## Current phase: A, core rework (Nov 2026 – Jan 2027)

Goal: the existing house and ranch play one full day of the new loop with placeholder art. Phase A does **not** include dialogue content, ghosts, rituals, Bruce's searches, the dump trip, selling items, or new maps. Leave a `TODO(phase-b)` where those will connect, and don't build them.

## Core rules the code must follow (GDD section 5)

- **Time (5.1):** the clock never ticks on its own. Every action calls `GameClock.advance(minutes)`. Anchors: wake at 7 AM, dinner at 6 PM, bedtime at midnight. Action costs live in one data table (`ActionCosts`) and are not hard-coded at call sites.
- **Meters (5.2):** Spirit (emotional) and Body (physical), both 0–100. They replace Gas. Sleep resets Body to that night's cap.
- **Voices (5.3):** Sight, Grit, Heart, Nerve. Levels 1–4; every voice starts at level 1. Actions and options are tagged with a voice and earn raw points, which settle into levels on Friday (therapy). Checks are 2d6 + level ≥ difficulty, with +1 if Spirit is 70 or more and −1 if it is 30 or less.
- **House (5.6):** needs are visible mess and requests, not a weekday checklist. Needles are the family's jabs, each with four voice responses.
- **Money (5.10):** a shared jar (groceries about $60 every Saturday) and the teen's hidden stash.
- **Ranch (5.8):** clear junk piles by sorting; three "crops": workbench repairs (one step a day, drying overnight), jam, and an herb planter. No farming tools, seeds or soil tiles.
- **Cut:** homeschool (the `School` autoload), mowing, babysitting, the real-time clock tick, Gas.

## Code conventions

- Godot 4.7, GL Compatibility, GDScript only.
- **Autoloads:** EventBus, GameState, GameClock, SceneRouter, Mom, ChoreSystem, QuestSystem, Inventory, Cooking, School (to be removed), SaveSystem, HUD, Data, Enum, DialogueManager.
- Systems talk through `EventBus` signals. Don't reach across autoloads for UI updates.
- Content is data: `.tres` resources under `data/` with a matching `*_data.gd` script. Don't hard-code content in scripts.
- Interactables extend the shared Interactable base (see `props/crate/crate.gd` for the pattern). Use `ChoiceMenu.open(title, options, cancel_text)` for simple menus.
- Anything that should persist goes in `GameState` and its `to_dict` / `from_dict`. Bump the save version when the shape changes.
- **Tests:** smoke scenes in `dev/` (`*_smoke.gd` / `.tscn`). Add or update a smoke test with every system change, and run them all before committing (`dev/run_smokes.sh` once A-03 has created it).
- Placeholder art is fine. Don't spend time on final art in Phase A.

## Working rules

- Stay inside the current issue's scope. If something else is needed, say so and suggest a new issue rather than widening the change.
- One in, one out: a new feature replaces something on the list, or goes to "Later".
- Mature subject matter (drinking, verbal abuse) is shown directly but never gratuitously. Oscar never dies.
