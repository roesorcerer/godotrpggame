# Demo build list

**The demo is week 1 of the summer (June 12–18, 2006): about 60–90 minutes, about 570 hours of work, built in the order below. Tick items off as you go.**

## What the demo is

- **Content:** the tutorial week from the Summer calendar tab, days 1–7: Dad's letter, the move-in, the lean-to and workbench, Bruce's barn, cans and the dump, meeting Lilith, the first therapy session with Eli, the first trip to Pine Grove, and Sunday's warm dinner with Mom's "just one glass."
- **Where it ends:** Sunday night (day 7). After the second glass, the teen goes to bed and the **first ghost appears for a moment**: Elsie at the window if Sight is your stronger voice, or Tracy on the trail if it's Nerve. Then a "to be continued / wishlist on Steam" card. In v1.0 only Elsie and Tracy appear, so the demo uses whichever of Sight or Nerve is higher.
- **Length:** 60–90 minutes on a first play.
- **Definition of done:**
  - A stranger plays start to finish with no help and no blocking bugs.
  - Afterward they can say in a sentence what the game is about.
  - At least 3 of 5 playtesters say they want to keep playing.
  - Windows, Mac and Linux builds run; the demo is on itch.io and attached to the Steam page.

## Hours at a glance

| Area | Hours | Notes |
| --- | --- | --- |
| Phase A: core rework | 156 | Code; placeholder art |
| Maps | 113 | 5 areas on LimeZu tiles |
| Characters | 36 | 2–3 teen presets, 7 others |
| Systems | 105 | Menus, rides, store, therapy, notebook, ending |
| Writing | 74 | About 9,000 words |
| Audio | 15 | 2–3 loops, about 25 effects |
| Phase C: polish and ship | 70 | Two playtests, builds, store pages |
| **Total** | **about 570** | About 9 months at 15 hrs/week (Nov 2026 – Aug 2027) |

That's slightly over section 11.3's 550 hours for M4 and M5, so expect to use the cut list below.

## Phase A: core rework (M4, about 150 hours, Nov 2026 – Jan 2027)

Goal: the existing house and ranch play one full day of the new loop with placeholder art. Hours in brackets.

**Clean-up**

- [ ] Rename the project from `stardewclone` to Pine Grove \[1\]
- [ ] Remove the homeschool `School` autoload, subjects and the schoolwork chore \[2\]
- [ ] Remove seeds and watering from `ranch.gd` and the hotbar; keep the tool-on-tile code for clearing \[3\]

**Time and meters**

- [ ] `GameClock`: turn off the real-time tick; every action calls `advance(minutes)`; anchors at 6 PM dinner and midnight bedtime; wake at 7 AM \[12\]
- [ ] Spirit and Body replace Gas in `GameState` and the HUD; sleep resets Body to the night's cap; food restores Body \[12\]
- [ ] For the demo only: Spirit and Body can't drop below 10 (no breakdowns in week 1) \[1\]

**Voices and choices**

- [ ] Four voices (Sight, Grit, Heart, Nerve): points, levels 1–4, voice tags on actions \[12\]
- [ ] Voice-tagged dialogue options and passive voice lines through the Dialogue Manager addon \[15\]
- [ ] Raw points that settle on Friday (therapy hook) \[4\]

**The house**

- [ ] Needles: a data file of lines, triggers by room and action, and the four voice responses (reuse `ChoiceMenu`) \[18\]
- [ ] Needs: rework `ChoreSystem` and `MessProp` into visible needs (dishes, empties, Oscar's meals when Mom can't) \[12\]
- [ ] Mom feeds Oscar unless a flag says she can't; "feed yourself" from the fridge \[6\]
- [ ] Bruce's territory: barn and recliner off-limits; walking in triggers him \[5\]

**Money**

- [ ] The jar and the fridge calendar: one screen showing the balance, what's due and pay-in \[10\]
- [ ] Your stash (hidden money); searches can wait until v1.0 \[3\]

**The ranch**

- [ ] Junk piles: sort into trash, cans, scrap, salvage or a find (reuse `Crate` and `ItemPickup`) \[14\]
- [ ] Zones: the lean-to and the front yard, plus a locked car graveyard for week 2 \[6\]
- [ ] Workbench: a multi-day repair with daily steps and drying overnight; 2 repairs (lamp, transistor radio) \[10\]
- [ ] Herb planter: plant cuttings, water each morning, harvest \[4\]

## Phase B: demo content (M5, about 345 hours, Feb – Jul 2027)

Goal: all seven days playable start to finish. Build each day's beat with gray boxes first, then art.

**Maps** (LimeZu tiles and props)

- [ ] Ranch exterior: the lean-to, front yard, car graveyard (locked), trampoline, barn door \[18\]
- [ ] House: add the teen's room (bed, desk, ritual corner), Oscar's room, and the barn workshop interior \[22\]
- [ ] Woods trail between the ranch and Pine Grove (small) \[8\]
- [ ] Pine Grove v1: entrance, the job board, the pool and bathhouse (unrestored), the lodge with its bingo room \[35\]
- [ ] Cobble Creek: one street with the store, library, thrift store and dump recycling, and the interior of Eli's office (rework the current `pine_grove.tscn` map) \[30\]

**Characters** (sprites and portraits; check whether the LimeZu license covers its character generator)

- [ ] The teen: 2–3 preset looks with walk, sit, work and sleep animations \[12\]
- [ ] Mom, Bruce and Oscar (sprites exist: add portraits and missing animations) \[8\]
- [ ] Lilith, Eli, Benny and Dot: sprites and portraits \[16\]

**Systems**

- [ ] Title screen, new game and continue, options (volume, text speed, content-warning toggle), content-warning screen, resources screen \[18\]
- [ ] Light character creator: name, pronouns, preset look \[8\]
- [ ] Opening: Dad's letter and the drive-up voice choice (one voice +1) \[6\]
- [ ] Asking Mom for a ride, and the travel transition to town \[6\]
- [ ] Store: buy groceries with jar money (the budget choice) \[6\]
- [ ] Dump recycling: cans to cash \[3\]
- [ ] eBay: list a find over dial-up at night (the auction resolves in week 2, after the demo) \[8\]
- [ ] Lilith's notebook: write from a few choices; her reply comes at the next swap \[10\]
- [ ] Therapy: Eli's first session, the sharing choice, the first reframe, points settle \[14\]
- [ ] Pine Grove job board (one job: clear brush), one salvage pile, the bathhouse project's first step \[10\]
- [ ] Night: the day summary in the notebook, then autosave (rework the existing day-end summary) \[5\]
- [ ] Day 7: the scripted "just one glass" scene with the Sight passive check \[3\]
- [ ] The demo ending: the ghost glimpse (Elsie or Tracy), then the end card \[8\]

**Writing** (about 9,000 words)

- [ ] The seven days' scenes as in the Summer calendar tab's week 1 (about 5,000 words) \[40\]
- [ ] Needles: about 40 lines across Mom, Bruce and Oscar \[8\]
- [ ] Voice lines: about 15 per voice \[10\]
- [ ] Eli's first session (about 1,000 words) \[6\]
- [ ] Lilith's first 3 notebook replies \[4\]
- [ ] Items, repairs, eBay listings and UI text \[6\]

**Audio**

- [ ] 2–3 music loops (royalty-free or commissioned) and about 25 sound effects \[15\]

## Phase C: polish, playtest and ship (about 70 hours, Jul – Aug 2027)

- [ ] Playtest round 1 with 3–5 people: watch, don't explain, write down where they get stuck \[6\]
- [ ] Fix pass from round 1: bugs, confusing prompts, pacing \[20\]
- [ ] Playtest round 2, then a final fix pass \[12\]
- [ ] Tune the week: action costs, Spirit and Body drain, money amounts, needle frequency \[8\]
- [ ] Export Windows, Mac and Linux builds and test each \[4\]
- [ ] itch.io page: description, screenshots, content warnings \[3\]
- [ ] Steam page: capsule art, 5 screenshots, a 30–60 second trailer, description, tags; pay the $100 fee; upload the demo \[15\]
- [ ] Register the demo for Steam Next Fest (October 2027; check the deadline) \[2\]

## Not in the demo

These come in M6 (weeks 2–4) and aren't needed for week 1: the random drinking model, ghost stories past the first glimpse, rituals, hallucinations, the walk home and sick day, Disclosure effects, searches, Bruce's branch point, the bike, jam, bingo games (the lodge exists; bingo starts in week 2), and the crisis night.

## If the demo runs over budget

Cut in this order, then bring it back in M6:

1. eBay listing (keep finds; sell them in week 2)
2. The lodge's bingo room (show the lodge from outside)
3. The third character preset
4. The barn workshop interior (Bruce throws you out at the door)
5. Herbs (Lilith's cuttings arrive in week 2)

Never cut from the demo: the house and needles, the voices, Oscar, Lilith and the notebook, Eli's session, Pine Grove's first visit, and the ghost glimpse at the end.
