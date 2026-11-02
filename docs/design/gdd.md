# Pine Grove — Game Design Doc

Oct 28, 2026 · @Rowan

## 0. Decisions & open questions

**v0.3: a narrative life sim about a teen in a poor, alcoholic home who builds a self out of four inner voices and the ghosts of a dying Northern California resort.** The core is decided: the time model, the meters, the ranch and its three crops, Pine Grove's restoration, the ghosts, and the cast. What's left is detail and scope (0.2). Rows marked "superseded" in the log were replaced by a later row.

### 0.1 Decision log

| # | Decision | Replaces |
| --- | --- | --- |
| 1 | One 84-day summer | Teen, then young-adult phases |
| 2 | No school: it's summer (homeschool cut, see row 41) | Classes mapped to D&D stats |
| 3 | Mature rating; abuse and drinking shown directly | — |
| 4 | Oscar is the younger brother. He lives with you and bullies you, and you protect him anyway. | — |
| 5 | Dad lost custody of both kids because of his own addiction and says goodbye in a letter | Vague "traumatic event" |
| 6 | **Cobble Creek** is the small town. **Pine Grove** is a run-down resort facing a buyout that the player helps save. | Pine Grove as the town |
| 7 | **A clock that moves only when you act, plus Spirit and Body meters** | Gas energy and the real-time clock |
| 8 | Housework appears as **visible needs plus spoken requests** | Weekday chore checklist |
| 9 | **Ghosts** replace Disco Elysium's skills and Thought Cabinet. They are taken in through **rituals**. | Skill XP as the identity system |
| 10 | Ghosts are **ambiguous**: never confirmed real or imagined | "No magic" pillar |
| 11 | Ghosts are **past people of the resort and Cobble Creek** whose lives echo a path the teen could take | — |
| 12 | Witchcraft comes from **a friend** and from a **weekly required therapist**, the only safe adult who encourages it. Therapy locks in the week's growth. | — |
| 13 | The dark path is **coping habits** that slowly take over | — |
| 14 | Farming tools and the garden are cut | Axe, shovel, watering can, seeds |
| 15 | 4 deep ghosts (springs girl, steam worker, caretaker's wife, girl on the grade); hold at most 3 | 6-ghost roster |
| 16 | The emotional meter is called Spirit | Composure |
| 17 | Therapy is court-ordered; Mom drives, so drinking nights can make you miss it | — |
| 18 | Pine Grove is saved through one Revival score fed by restoring areas, bringing people back, laying ghosts to rest and raising money | Campaign fund only |
| 19 | Game title: Pine Grove. Town: Cobble Creek (fictional) | Cobb Mountain / Cobb (real places) |
| 20 | Bruce's arc runs from cold to hostile, with one crack (no ally path) | — |
| 21 | Lilith is the witchcraft friend: funny, talks through a shared notebook, the first crush, unrequited | — |
| 22 | Modular epilogue: 4 outcomes x 3 states | Open ending count |
| 23 | Pine Grove can be saved, partly saved or lost (Revival thresholds) | — |
| 24 | Hobbies: mix CDs, disposable camera, handheld games, MySpace, AIM and Neopets | Trampoline-only fun |
| 25 | Therapy is on Fridays | — |
| 26 | Rename the Godot project from stardewclone to Pine Grove | stardewclone |
| 27 | Ghosts are Northern California locals from Pine Grove's eras ("What the Mountain Keeps"): a girl who died of TB, a steam worker, a caretaker's wife, a girl on the grade. All are unreliable, each has its own tone, and each loosely mirrors the family. | Independent ghosts |
| 28 | Four inner voices (Sight, Grit, Heart, Nerve) are the attributes from day 1; ghosts give them faces when a voice reaches level 3 | Ghosts on fixed weekly windows |
| 29 | Drinking nights are random: rising hazard, clustering, promises, and a pacing director | Fixed nights per week |
| 30 | Daily loop: Read, Choose, Act, Reflect (superseded by 34) | — |
| 31 | Money: the jar and fridge calendar; teen income sources taught in week 1 (sources revised in 36) | Unspecified economy |
| 32 | Bruce has no job: a spent inheritance, car repairs and guitar | Bruce "works late" |
| 33 | Disclosure tiers: no one / more time away from home / a social worker, after which home gets worse | — |
| 34 | Daily loop: survive the house, escape to Pine Grove, bring something back, write it down | Read, Choose, Act, Reflect |
| 35 | Needles: the family criticizes everything, answered by a voice; doing everything right never stops it | — |
| 36 | Teen income: job board, blackberries, eBay reselling, cans at the dump. Town trips need Mom's ride. | Helping Bruce, neighbor jobs |
| 37 | Hiding money is punishable: searches, grounding, lost rides, confiscation | Hiding as a safe option |
| 38 | Pine Grove restoration as bundle-style projects (salvage, supplies, hands, fund) | Unspecified restoration |
| 39 | Mom's income is sex work, implied and never shown. She overshares and treats the teen as her only friend. | — |
| 40 | Mom's family in Redding is estranged; backstory only | Mom's sister in Santa Rosa |
| 41 | No school during the summer: homeschool is removed entirely | Homeschool workbooks (decision 2) |
| 42 | Golden child and scapegoat: Mom cares for Oscar unless she's drunk; she never cares for the teen | The teen feeds Oscar every day |
| 43 | The farm analogue: clear ranch junk and Bruce's hoard for salvage; mornings are ranch time | Homeschool mornings |
| 44 | Three crops: workbench repairs (main), blackberry jam (seasonal), witch's herbs (daily) | No crop |
| 45 | The teen has a small room of their own; taking from Bruce's hoard is a risky gamble | — |
| 46 | Time is a clock that moves only when you act; actions cost hours; about 8–12 actions and 10 real minutes per day | Four time slots |
| 47 | Two meters: Spirit (emotional) and Body (sleep, food, growth spurts) | Spirit only |
| 48 | Low Spirit brings Don't Starve–style shadow hallucinations built from your history; reframes from therapy counter them; zero in either meter means a sick day in bed | Shutdown day |
| 49 | At 0 Spirit or Body the teen walks home through hallucinations (or calls from a payphone in town); then a playable sick day with fever dreams that reveal backstory | Pass out and lose the day |
| 50 | Both meters at 0: the police bring you home (Disclosure +25). Repeated breakdowns build Burnout (lower caps, faster shadows). Backstory also comes from good nights, so crashing isn't rewarded. | — |
| 51 | Therapist: Eli Brightwater, an older gentle man, the first kind man in the teen's life | Unnamed therapist |
| 52 | Pine Grove's owners: Benny and Dot (renamed from the real couple); nightly bingo with "B for what? B for BENNY!" | A generic owner |
| 53 | Lilith (Danielle): absent parents, a double-wide with Ola and tarantulas, never visits; the teen has to get there | Lilith's mom as a helper |
| 54 | Solo developer at about 15 hrs/week; Matt helps occasionally | Designer plus Matt |
| 55 | v1.0 is a 4-week summer (Jun 12 – Jul 9), 3–5 hours, with Elsie and Tracy; the 12-week, 4-ghost game is the long-term vision | 84 days for the first release |
| 56 | Release: a free week-1 demo (about Aug 2027), Steam Next Fest, then v1.0 on Steam for PC (about fall 2028) | No release plan |
| 57 | In v1.0 the crisis night falls on the Fourth of July and the buyout meeting on day 28 | Crisis on Aug 19, buyout on day 84 |
| 58 | Oscar is about a year younger. He bullies because he learned it, to stay the golden child, and because he misses Dad. He fears Mom will leave too. Trust grows from small daily acts plus four weekly beats. | A much younger brother |
| 59 | Endings: a jump to summer 2016, 4 slides with set conditions, every ending bittersweet, and a final playable scene at the Pine Grove pool | 4 slides with no conditions |
| 60 | The ending is sorrow and loss: a return after years of longing where things look the same but home is gone. The 2015 fire is mentioned lightly as the theme of repeated mistakes. | Bittersweet endings; the fire undecided |
| 61 | The demo is week 1, about 570 hours in three phases, and ends Sunday night on a glimpse of Elsie or Tracy | A loosely defined vertical slice |

### 0.2 Still open

Ticked items are decided. Unticked items are the next round, in priority order.

- [x] **Mom's income, Lilith, Mom's family, the therapist, Pine Grove's owners, Lilith's family.** All decided (8.2, 8.3).
- [x] **Pine Grove's setting.** Pools, not a lake, matching the real resort.
- [x] **1. Oscar's arc.** Done (8.2.1). Open: exact ages, and whether the proposed backstory secret fits.
- [x] **2.** Ending conditions. Done (7.5): ten years later, 4 slides, a final scene at the pool. The 2015 fire is mentioned lightly.
- [x] **3.** Scope and production plan. Done (section 11): a 4-week, 3–5 hour v1.0 with 2 ghosts, a demo first, solo at about 15 hours a week.
- [x] **4. Week-1 vertical slice.** Done: see the Demo build list tab (about 570 hours, ending on a ghost glimpse).
- [ ] **5. The family's beats.** Mom's and Bruce's week-by-week story beats beyond the branch points: Mom's "promise" arc, her dates, the bank letter.
- [ ] **6. Supporting cast.** Names and roles for Kevin, Danny, the librarian, the bartender, 2–3 resort regulars, a Mayacamas rep, and the social worker.
- [ ] **7. UI screens.** Mockups for the notebook, the family computer (eBay, MySpace, mix CDs), the workbench, the ritual screen, the ghost journal and the jar.
- [ ] **8. Real people.** Benny, Dot and Lilith are renamed. If Mom, Bruce, Oscar or Dad are drawn from real people too, decide how to protect them (names, details, who sees the game first).
- [ ] **9. Tuning pass.** A spreadsheet of action costs, wages, prices, needle frequency, voice-point thresholds and drinking odds, then a playtest.

## 1. Introduction

### 1.1 Scope of this document

This GDD is the source of truth for a solo developer, with occasional help from Matt (art and writing). It records decisions made, flags the ones still open, and notes where the Godot build has to change to match. When code and this doc disagree, raise it and update one of them.

**Title:** *Pine Grove*, after the resort. The town is the fictional **Cobble Creek**, which replaces the real places Cobb and Cobb Mountain, CA. Rename the Godot project from `stardewclone` to match.

### 1.2 Elevator pitch

**One summer. A family that's drowning. A resort full of ghosts. Who will you become?**

It's the mid-2000s. After Dad loses custody to his addiction, a teen and their younger brother Oscar move to a run-down ranch outside the small town of Cobble Creek, with their mom Doris and her new husband Bruce. Both adults drink. Money is short.

Over one summer the teen keeps the house afloat, protects a brother who bullies them, and finds escape at **Pine Grove**, a fading mountain resort with spring-fed pools, about to be bought out. There, the ghosts of the resort's past start to speak. Through a friend, a therapist and the rituals of a budding teenage witch, the player chooses which ghosts to take in. Those choices shape who the teen becomes: a young adult who is emotionally strong, or one who sinks into the same coping habits that are drowning their family.

**Design statement (the experience goal):** the player should feel what it's like to build a self out of whatever is around you when the adults can't hold you, and see that the self they built was a choice.

## 2. MDA framing

The game is built backwards from three target aesthetics: **Narrative, Expression and Fantasy.** Every mechanic must serve at least one of them.

MDA (Hunicke, LeBlanc & Zubek, 2004) splits a game into **Mechanics** (rules and data), **Dynamics** (the behavior that comes out when a player meets those rules) and **Aesthetics** (the emotions the player feels). Designers build from M toward A; players feel A first. So we pick the feelings first, then test every system against them.

### 2.1 Target aesthetics (ranked)

| Rank | Aesthetic (MDA) | What it means here |
| --- | --- | --- |
| 1 | Narrative | A coming-of-age drama about poverty, addiction and a kid who becomes the adult. |
| 2 | Expression | Who you become. You pick the ghosts you take in, the habits you build and the person you choose to be. Like Disco Elysium, the character is the player's work. |
| 3 | Fantasy | Being a teen witch whom the dead speak to. A private power no adult can take away. |
| 4 | Fellowship (in-fiction) | Friends at Pine Grove and the therapist: the people who see you. |
| 5 | Submission (comfort) | The rhythm of the day and the resort's lazy summer. Soothing, and also the trap. |
| — | Challenge (as pressure) | Never "hard." Too few hours for everyone's needs, and Spirit drained by home. |
| — | Discovery | The resort's history, each ghost's story, secrets in Cobble Creek. |

### 2.2 Aesthetic → Dynamic → Mechanic map

| Aesthetic | Dynamic we want | Mechanics that produce it |
| --- | --- | --- |
| Narrative | The player notices the family leaning harder on them each week | Escalating household needs and requests; random drinking nights (5.15); Mom's mood; Oscar's wellbeing |
| Expression | Players compare "who they became" and replay to become someone else | Ghosts taken in through rituals; therapy locks them in each week; coping habits; dialogue choices |
| Fantasy | Night rituals feel private, powerful and a little dangerous | Ritual space in your room; ghost encounters at the resort; ghost voices in dialogue |
| Fellowship | Pine Grove feels like relief | Friends, resort activities, the therapist, a few adults who notice if you let them |
| Submission | A readable daily rhythm | A clock that moves only when you act; a short morning ritual of checking the house |
| Challenge | Every hour is a trade-off between home, Oscar, yourself and the resort | Limited hours; Body and Spirit drain and recovery; money |

### 2.3 Design pillars

Use these to cut or keep features. If a feature doesn't serve a pillar, it waits.

1. **The house always needs something.** There is never enough time to meet everyone's needs, including your own.
2. **You build yourself from what's around you.** Ghosts, friends, habits: identity comes from what you choose to take in.
3. **No villains, only people.** Mom, Bruce and Oscar are flawed, never cartoon monsters. Warmth and harm come from the same person.
4. **Grounded, with one door left open.** A real 2000s small town, but the ghosts are never explained away. They might be real, or they might be you.

*Source: Hunicke, LeBlanc & Zubek, "MDA: A Formal Approach to Game Design and Game Research" (AAAI Workshop on Challenges in Game AI, 2004), [PDF](https://users.cs.northwestern.edu/~hunicke/MDA.pdf). It names eight aesthetics: Sensation, Fantasy, Narrative, Challenge, Fellowship, Discovery, Expression, Submission. MDA treats Fellowship as mostly about multiplayer ([MDA framework, Wikipedia](https://en.wikipedia.org/wiki/MDA_framework)), which is why it's "in-fiction" here. Checked October 29, 2026.*

## 3. Game overview

### 3.1 Concept

A single-player, top-down 2D narrative life sim set over one summer in the mid-2000s. You play a teen raising themselves (and their younger brother) in a home shaped by poverty and alcoholism. Days are split between home, the run-down Pine Grove resort and the teen's own inner life. Identity grows through ghosts the teen chooses to take in through rituals, a system inspired by Disco Elysium's skills and Thought Cabinet.

### 3.2 Audience

- **Primary:** adults aged 25 to 40 who grew up in the 2000s and play story-driven games (Disco Elysium, Night in the Woods, Spiritfarer) and cozy sims (Stardew Valley).
- **Secondary:** players who grew up in addicted or unstable homes, and players drawn to witchy and supernatural coming-of-age stories.
- **Rating target:** Mature (ESRB M / PEGI 16 range, to confirm). Alcohol use, verbal abuse, poverty and parentification are shown directly.

### 3.3 Genre

**Narrative life sim with an identity-building system.** It borrows farming-sim structure (a calendar, daily choices, relationships) and Disco Elysium's idea that the character is what the player chooses to internalize.

**Comparable games:** Disco Elysium (identity, inner voices), Night in the Woods (tone, small town), Spiritfarer (ghosts with stories, grief), Persona (time pressure), Stardew Valley (structure).

### 3.4 Setting

The real world, mid-2000s (proposed: summer 2006). A rundown ranch outside **Cobble Creek**, a small mountain town. Nearby is **Pine Grove**, a once-popular mountain resort in the pines, with spring-fed pools, that is now crumbling, and a developer wants to buy it out. The world is grounded; the ghosts are the one thing never explained.

### 3.5 World structure

An **open hub** of three main areas, reached by walking, biking or getting a ride:

- **The ranch:** home. Inside are the kitchen, living room, bathroom and halls, plus the teen's room with its ritual space. Outside are the yard, barn, stable, water tower and trampoline.
- **Cobble Creek (town):** the store, the library, the post office, the dump, the therapist's office, the church basement where Alateen meets, and the bar Mom and Bruce go to. Small-town eyes that half-see what's happening at home.
- **Pine Grove (resort):** escape, friends, summer activities and the ghosts. The place you're trying to save. Also on the map: the woods trail and the creek between the ranch and Pine Grove, Lilith's double-wide out on open land, and the mountain grade toward the valley.

### 3.6 Player

Single-player. One teen with a light character creator: name, appearance, pronouns. The backstory is fixed (Section 7). Who the teen *becomes* is shaped by play: ghosts, habits, relationships and choices.

### 3.7 Core loop

**Every day: survive the house, escape to Pine Grove, bring something back, write it down.** Home is a pressure cooker with things to do *and* people tearing you down while you do them. Pine Grove is the progress loop, the "farm." Night is private: Lilith's notebook, rituals and eBay.

| Time of day | Where | What the player does | What's at stake |
| --- | --- | --- | --- |
| **Morning** | Home | Read the house: who's hungover, what's broken, what's missing, warning signs. If Mom is out cold, feed Oscar (otherwise she does); feed yourself. Deal with last night's damage. Then ranch time: water the herbs, do the day's workbench step, clear a pile (5.8). | Oscar's wellbeing, Mom's mood, Spirit; the family's needles (5.6) |
| **Afternoon** | Pine Grove (on foot), or town if Mom will drive | Pine Grove: the job board, restoration projects, salvage, blackberries, Lilith, ghosts. Town: the dump (cans, salvage), store, post office (eBay shipping), library, Alateen, Friday therapy. | Money, Revival, Lilith, the ghosts |
| **Evening** | Home | Dinner (Mom cooks for Oscar if she's able; otherwise you do), the family scene (needles, Mom's confidences), the drinking-night roll, damage control, staying out of Bruce's way. Or skip all of it for bingo at Pine Grove (5.13.3) | The house, Oscar, Spirit |
| **Night** | Your room | Write in Lilith's notebook (the day's reflection), list eBay finds on dial-up (if the phone line is free), a ritual, sneak out, or sleep | Spirit, Lilith, ghosts, money |

**Every day ends with something that moved:** a repair one step closer, herbs growing, jam setting, a zone cleared, money in your stash, Lilith's reply, an eBay auction ticking down. That's the Stardew "one more day" pull, built from a teenager's life.

**Goals at three time scales:**

| Scale | The player is working toward |
| --- | --- |
| Today | Getting Oscar fed, getting through the needles with Spirit left, earning something, getting out |
| This week | The jar's Saturday share (or the risk of holding back), one Pine Grove project, a ride to town for the dump and post office, Friday therapy (what to share, what to reframe) |
| The summer | Revival 60+ by September 3; Oscar safe; the ghosts' stories; who you become |

### 3.8 Look & feel

**Look:** 16x16 top-down pixel art (LimeZu Modern series), a warm summer palette with lived-in clutter at home. Ghosts are drawn in a distinct, faded style so they read as "other" at a glance.

**Feel:** comforting on the surface, heavy underneath, and quietly eerie at night. Mundane details (Bruce's ashtrays, empty fridge, the shutoff notice) carry the story.

## 4. Gameplay

### 4.1 Objectives

The player juggles **four threads**, and no single one is "the" goal. The tension between them is the game.

| Thread | What the player is trying to do | Measured by |
| --- | --- | --- |
| **Find yourself** | Build an identity in spite of home | Ghosts taken in, habits, friendships, Spirit trend |
| **Protect Oscar** | Keep a younger brother who bullies you fed, safe and on track | Oscar's wellbeing and his trust in you |
| **Hold the family together** | Keep the house running through poverty and drinking | Household state, Mom's mood, money, utilities on or off |
| **Save Pine Grove** | Help the resort survive the buyout on day 84 | Pine Grove Revival score (5.13) |

> Design note: the threads should collide on purpose. The resort's big night falls on a drinking night. Oscar needs you the same afternoon your friend does. Therapy is the one place the player can talk about all of it.

### 4.2 Progression

There are no character levels. The teen progresses along two tracks:

- **Who you are:** ghosts you've internalized (Section 5.3). This is the Disco Elysium-style core.
- **How you cope:** healthy coping (friends, hobbies, rituals, therapy) versus unhealthy coping habits (5.5). Over the summer this tips the teen toward an emotionally strong ending or a dark one.

Relationships with Mom, Oscar, Bruce, friends, the therapist and the resort folk run alongside.

#### 4.2.1 Proposed 12-week arc

Five phases: Honeymoon (weeks 1–2), Cracks (3–5), Parentified (6–8), Breaking point (9–11, with the crisis night in week 10), Resolution (12). The full week-by-week plan, with dates, is in Summer calendar.

### 4.3 Play flow

The first week is the tutorial (9.3). After that, each week gives the player one scripted home beat, one therapy session, one or two resort or Cobble Creek events, and open hours in between. Players can't meet every need, and the game is tuned so that letting something slip is a real choice, not a failure state.

### 4.4 Difficulty

**One difficulty, tuned for story.** There is no game over. Pressure comes from limited hours, Body, Spirit and money. Accessibility options: gentler Spirit drain, and a toggle that softens the harshest scenes (7.6).

## 5. Mechanics & systems

Content stays data-driven: a new ghost, need, request, recipe or quest should be a `.tres` file, never a code change. Section 10 lists what has to change in the current build.

### 5.1 Time: a clock that moves when you act

**The day is a budget of hours, spent however the player chooses.** The clock runs from wake-up to bedtime but never ticks on its own: it advances only when you do something. It's turn-based and calm, with real choice. Hours spent on one path (rituals, work, Lilith, hobbies) are hours not spent on the others, and that trade-off is how the player shapes who the teen becomes.

**Action costs (tuning):**

| Cost | Actions |
| --- | --- |
| **Free** | Walking around the house, reading the house, short talks, checking the jar or calendar |
| **15–30 min** | Water herbs, eat, feed Oscar, write in Lilith's notebook, a quick look at the hoard |
| **1 hour** | A workbench step, a ritual, a MySpace, Neopets or eBay session on dial-up, the Game Boy, the trampoline, listening to Mom |
| **2 hours** | Clear a pile, a job-board shift, pick blackberries, a jam batch, salvage at Pine Grove |
| **Travel** | Walk to Pine Grove 45 min (bike 20 min); to town in Mom's car 30 min (if she agrees), or by bike 90 min each way once it's fixed |

**Fixed anchors** frame each day:

- **Wake-up:** 7 AM, later after a short night.
- **Dinner, 6 PM:** the family scene; skipping it has a cost.
- **Night:** on drinking nights, things start around 9 PM.
- **Bedtime, midnight:** staying up later costs tomorrow's Body (5.2).

That leaves about **13–14 hours of choices a day: roughly 8 to 12 actions and about 10 real minutes of play.** The four parts of the day (Morning, Afternoon, Evening, Night) remain as times of day, not as slots.

**No dead days.** Family events change *which* options are open, never *whether* there are options. On days Mom looks after Oscar, you get those hours back; those are the good days. On days Bruce is guarding the garage, the hoard is closed, but the crops, the yard, Pine Grove, hobbies, Lilith and the trail are always open.

**Code:** `GameClock` already has `advance(minutes)`. The real-time tick is turned off, and every action calls `advance`.

### 5.2 Spirit and Body

Two meters, matching a teenager's development: **Spirit** is the inner life (mood, self-esteem) and **Body** is the growing body (sleep, food, growth). Both run 0 to 100.

|  | **Spirit** (emotional) | **Body** (physical) |
| --- | --- | --- |
| **Drained by** | Needles, drinking nights, caretaking Mom, listening to her confidences, unmet needs, Oscar's bullying, hallucinations | Clearing, hauling, picking, biking, salvage; skipped meals; short sleep |
| **Restored by** | Lilith, Pine Grove friends, hobbies, rituals, Alateen, therapy (a lot); coping habits (fast, at a hidden cost: 5.5) | Food (nobody cooks for you, so you have to find it); sleep, which resets Body to that night's cap |
| **When it's low (under 25)** | Calm options lock; impulsive and angry options appear; hallucinations grow (5.2.1); coping habits tempt you | Physical actions take 50% longer; Grit checks −1; cranky options |
| **Teen development** | Mood swings and self-esteem tied to how others treat you | **Sleep:** a teen needs about 9 hours, so each hour short lowers tomorrow's cap. **Growth spurts:** one or two random weeks when hunger doubles. |

#### 5.2.1 Hallucinations: the shadows

As Spirit falls, the teen's mind starts to turn on them, like Don't Starve's sanity meter. These are the **shadows**, and unlike the ghosts they're clearly the teen's own mind.

| Spirit | What happens |
| --- | --- |
| 50–30 | **Whispers:** shadow lines in the HUD in the voices' dark forms ("They'd be better off without you") |
| 30–15 | **Distortions:** the house warps. Halls stretch, Bruce's guitar plays from an empty room, the jar looks full and then empty. Ghost lines may lie. |
| Under 15 | **Confrontations:** a shadow version of a ghost blocks your way and voices a distorted thought **built from what you've done so far** |

**Confrontations draw on the player's own history.** Each one is a negative thought pattern from CBT (cognitive behavioral therapy), aimed at something real:

| If you've... | The shadow says | Thought pattern |
| --- | --- | --- |
| Left Oscar alone on a bad night | Shadow-Elsie: "You left him like they left me." | Personalization |
| Been caught hiding money | "Thief. That's all you are." | Labeling |
| Leaned on coping habits | Shadow-June: "It's the only thing that helps. Just one." | Emotional reasoning |
| Had Lilith not return your feelings | "Nobody will ever want you." | Overgeneralization |
| Worked yourself to the bone | Shadow-Ray: "If you stop, it all falls apart." | Catastrophizing |
| Thought about leaving Oscar | Shadow-Tracy: "Go. They won't even notice." | Mind reading |

**Answering a shadow:**

- **Accept it:** the shadow wins. The voice's shadow grows and Spirit drops.
- **Fight it:** a Nerve check. It costs Spirit either way, but a win pushes the shadow back.
- **Reframe it:** use a **counter-thought** earned from a therapy reframe (5.3.1). It always works if you have the right one, restores a little Spirit, and shrinks that voice's shadow. Therapy literally arms you against your own mind.

#### 5.2.2 Breaking: the walk home

**When Spirit or Body hits 0, whatever you're doing stops, and you have to get yourself home.** Nobody carries you. That's the point: there's no one to carry you.

- **The activity ends where it is.** A half-done job is paid for the hours worked, an unfinished pile stays half cleared, and a jam batch scorches.
- **The walk home is a short playable sequence (2–4 minutes)** on the real map, but distorted:
  - **Spirit at 0:** the world drains of color, and paths stretch and loop. Ghosts from the past line the trail, along with memories of Dad's house and the family's voices. Each hallucination plays a **confrontation** from your own history (5.2.1): accept, fight or reframe. Accepting a shadow makes the path loop back (a longer walk). Reframing opens the way and lights it.
  - **Body at 0:** no hallucinations unless Spirit is also low. Your vision blurs, you move slowly, and you stop to rest. A passerby may help (Kevin on the trail, Danny's truck), depending on relationships.
  - **Both at 0: the police bring you home.** You don't make it. A sheriff's deputy finds you on the roadside or the trail, confused and half-hallucinating, and drives you home in the back of the cruiser. The shadows ride with you. It's the one breakdown you can't walk off, and it has real consequences (5.2.4): **Disclosure +25**, a deputy at the door seeing the state of the house (and maybe Mom), a likely call to county child welfare, and a furious Mom: "You brought cops to my house."
- **If you're in town,** you can't walk it in this state. Find the **payphone** and call home. Mom might come, angry or sweet depending on the day; she might not answer; or Bruce answers. While you wait at the curb, the shadows come anyway. With Disclosure 30 or more, you can call Pine Grove instead, and Benny comes down in his old truck.
- **How the walk goes shapes the sick day:** each reframed confrontation shortens it and shrinks a shadow, and each accepted one lengthens it.

At the door, the teen goes straight to bed and the **sick day** begins.

#### 5.2.3 The sick day

**A sick day is a short, room-bound chapter (about 4–6 minutes of play), not a blank screen.** The clock still advances on actions, but you can't leave your room without an effort. It runs through the rest of today and until about noon tomorrow (shorter if the walk home went well).

| From bed you can... | Cost | What it does |
| --- | --- | --- |
| **Sleep** | 3 hours | The main recovery. Each sleep triggers a **fever dream** (below). |
| **Listen through the walls** | 30 min | Eavesdrop on the house: Mom on the phone, a fight about money, Oscar asking where you are. Sight reveals more. It's a source of story and warnings ("there's no food in the house"). |
| **Game Boy, a book, the radio** | 1 hour | A little Spirit; no Body |
| **Write in Lilith's notebook** | 30 min | Spirit. Her next reply comes with extra warmth if she knows you're sick. |
| **Talk to a ghost** at the bedside | 30 min | Internalized ghosts sit with you. This is where their personal stories deepen most. |
| **Get up anyway** | Spirit, Body | Needed if Oscar is hungry on a drinking night. It costs recovery, but it's the parentified choice. |

**Fever dreams** are short playable vignettes that unlock **backstory you can't get anywhere else:**

- **Memories of Dad's house:** the good days, his drinking, and the night custody ended. They play in order across the summer. **Sick days are not the only way to see them:** a calm night's sleep after a ritual or a good day also brings the next memory, softly. On a sick day the same memory comes as a fever dream: darker, with more detail, and harder to sit through.
- **The ghosts' last days,** seen from inside: Elsie on the sleeping porch, the steam field the morning of the blowout.
- **When shadows are high,** dreams turn into nightmares, the same confrontations in dream form, with one more chance to reframe.

**Visitors at the door:**

- **Mom** mostly says "You're faking." Rarely, after a drinking night, she sits on the bed and apologizes for everything, which is worse.
- **Bruce** never comes.
- **Oscar** brings you crackers if his trust is high. If it's low, he takes your Game Boy.
- **Lilith's** notebook turns up on your windowsill.

**When you wake up,** Spirit and Body are partly restored (depending on how much you slept, and on the walk home), and the house shows what it went through without you.

#### 5.2.4 Pushing too far: burnout

**One sick day is a hard lesson. Repeated crashes are a spiral.** A hidden **Burnout** track counts breakdowns over the last 14 days.

| Breakdowns in 14 days | Consequence |
| --- | --- |
| **1** | The sick day itself. Needs pile up, one crop step is lost (a repair's glue cures crooked, herbs wilt), and a Pine Grove shift goes to someone else. |
| **2** | **Caps drop:** Spirit and Body can only refill to 80 for a week. Shadows grow twice as fast. Coping habits are offered more. Mom's "faking" needle becomes daily. |
| **3 or more** | **Burnout week:** caps drop to 60, all physical tasks are slower, a ghost you internalized starts speaking only in its shadow form, and Lilith writes "I'm worried about you." Each further crash adds Reliance. |
| **Any police pickup** | Everything above, plus Disclosure +25, a probable social worker visit (5.16), grounding, and the retaliation that follows |

**Recovery:** Burnout falls by one for every 4 days without a breakdown. Therapy, Alateen, a full night's sleep and a day with Lilith speed it up.

**Why it's balanced:**

- **The repair is real:** a sick day gives partial recovery, unique scenes and backstory.
- **The consequences are real:** lost hours, crop setbacks, needles, and lower caps if it happens again.
- **Backstory isn't a reward for crashing**, since good nights bring the same memories more gently. Players who crash learn the lesson the teen has to learn: you can't carry everything, and running yourself into the ground hurts the people you're trying to protect.
- **The Self epilogue tracks it:** a summer of repeated burnout pulls the ending toward the dark path.

### 5.3 Inner voices and ghosts: the attribute system

**The teen has four inner voices from the first minute of the game. They are the attributes.** Like Disco Elysium's skills, they speak up in dialogue, offer options, and pass or fail checks. The ghosts don't replace them; each ghost is what its voice looks like once it has a face. So the system works on day 1, and the ghosts arrive as the voices grow.

| Voice | What it is | Its ghost | Shadow side (when it goes wrong) |
| --- | --- | --- | --- |
| **Sight** | Noticing, intuition, reading people and signs, the spiritual | Elsie, the girl at the springs | Paranoia and isolation: "everyone's lying" |
| **Grit** | Working, fixing, providing, enduring | Ray, the steam worker | Numbness and overwork: "just keep going" |
| **Heart** | Empathy, caretaking, keeping the peace | June, the caretaker's wife | Despair: "close the curtains" |
| **Nerve** | Defiance, risk, standing up, getting out | Tracy, the girl on the grade | Recklessness and running: "leave them" |

#### 5.3.1 How voices grow

**You become what you do.** Every activity and every dialogue choice is tagged with a voice. Doing it earns that voice a point.

| You do this | Voice it grows | It also changes |
| --- | --- | --- |
| Read the house each morning, take photos, explore, do rituals | Sight | Spots drinking signs; ghost discovery |
| Work jobs (Pine Grove board, blackberries, cans), salvage and restore Pine Grove, keep the house running | Grit | Money, Revival, the house |
| Cook for the family, caretake Mom, comfort Oscar, keep the peace at dinner | Heart | Oscar's wellbeing, Mom's mood |
| Sneak out, refuse a request, stand up to Bruce, talk back | Nerve | Freedom; family trust drops |
| Dialogue choices in events (each option is voiced, e.g. "\[Nerve\] Tell Bruce to back off") | That voice | The scene's outcome |

- **Start:** every voice is at level 1. In the opening, the player answers "How did you get through living with Dad?", which gives one voice +1. That's the teen's starting personality.
- **Levels 1 to 6.** About 3, 7, 12, 18 and 25 points reach levels 2 through 6.
- **Points settle on Friday.** A week's points are "raw" until therapy. There, the teen can **reframe** one event, moving its points to a different voice ("I didn't run because I was scared, I ran to get help"). That's the core idea of real therapy as a mechanic. Each reframe also gives the teen a **counter-thought** to use against the shadows (5.2.1). If therapy is missed, points settle Sunday night with no reframe.
- **Voices never go down. Their shadow can go up.** Each voice has a shadow meter, 0 to 6:
  - **It grows from:** coping habits (5.5) and acting while Spirit is empty.
  - **It shrinks from:** therapy reframes, Alateen meetings and friends.
  - **When a voice's shadow is at or above its level, it speaks in its shadow form.** Its lines turn dark and its checks can backfire. The dark ending is the shadows taking over.

#### 5.3.2 Checks

- **Passive:** if a voice is high enough, an extra line appears. For example, Sight 3: *"There's a paper bag in Bruce's truck."*
- **Active:** roll 2d6, add the voice's level, then +1 if Spirit is 70 or more, or −1 if it's 30 or less. Beat the difficulty (7 to 13). Ordinary checks can be retried after a level-up. Key moments, like crisis night, are one-shot red checks.

#### 5.3.3 When the ghosts arrive

- **A voice that reaches level 3 draws its ghost.** The ghost appears at its Pine Grove area on your next visit.
- **Ghosts come in the order you build your voices.** Your strongest voice's ghost usually appears in **week 2**, the next by about week 4, and a third by week 6. The fourth comes only if you've grown all four voices.
- **Before a ghost appears,** its voice speaks as a plain inner voice (italic text, no portrait). Once you meet the ghost, it speaks with their face and personality.
- **Internalize (night ritual, then locked in on Friday):** the voice's cap rises from 4 to 6, and you gain the ghost's gift and cost (8.4). You can internalize at most 3. Once you know a ghost's truth, its voice speaks more honestly.
- **Lay to rest:** the voice stays capped at 4 with no gift, but its shadow resets to 0 and can never grow again. Its Pine Grove area heals (5.13).

**Other attributes:** Spirit (daily state, 5.2), money, relationships (5.7) and Revival (5.13). Hidden: Reliance (5.5), Disclosure (5.16) and drinking pressure (5.15). The build's homeschool system (subjects, grades, the answer key, Honesty) is cut, because it's summer.

### 5.4 Rituals & witchcraft

The ritual space is a corner of your room that grows over the summer: candles, herbs, a thrifted tarot deck, found tokens.

- **Sources:** your friend (practice, items, 2000s witch culture like *The Craft* and *Charmed*) and the therapist, the only adult who treats it as a healthy way to express yourself.
- **Rituals:** invite a ghost, release a ghost, protection for Oscar (lowers bullying for a day), calm (restores Spirit), and seasonal rites tied to story beats.
- **Ingredients:** herbs from your own planters (5.8.2), candles and a tarot deck from the Cobble Creek thrift store, tokens found at the resort, or things taken from home. Taking from home is noticed.
- **Risk:** caught by Mom or Bruce means a fight and lost Spirit. Oscar finding out can go either way.

### 5.5 Coping habits: the dark path

Habits are offered as relief when Spirit is low. Each one restores a lot of Spirit right away and adds to a hidden **Reliance** track.

| Habit | Offered when | Fast relief | Hidden cost |
| --- | --- | --- | --- |
| Sneaking Bruce's beer | After a drinking night | Big Spirit boost | Reliance up; the caretaker's wife is drawn; risk of being caught |
| All-nighters | Low Spirit at Night | Spirit up tonight | Lose tomorrow's Morning |
| Isolating (skip everything) | Any time | Spirit up a little | Relationships fade; needs pile up |
| Lashing out at Oscar | After his bullying | Spirit up | Oscar's trust down; mirrors Bruce |

As Reliance rises, habits are offered more often and give less relief, the classic tolerance curve. It is shown honestly and never glamorized. Healthy coping (friends, hobbies, rituals, therapy) lowers Reliance over time. **Reliance plus your internalized ghosts decide whether the epilogue shows an emotionally strong young adult or one following their family.**

### 5.6 The house: needs and needles

**The house asks for everything and thanks you for nothing.** Its needs are concrete and visible. Meeting them never stops the criticism; it only takes away the family's ammunition.

#### 5.6.1 What the house needs

| Need | What the player does | If it's ignored |
| --- | --- | --- |
| **Oscar, when Mom can't** | Oscar is Mom's baby: she cooks and cleans for him. When she's too drunk, hungover or out on a "date," it falls to you: making sure he eats, gets home, and isn't out alone at night. | Oscar's wellbeing drops, his bullying gets worse, and Mom blames you |
| **Yourself** | Nobody cooks for you. Eat Oscar's leftovers, make a sandwich before Bruce finishes the bread, buy your own food, or trade jam and eggs at the lodge kitchen. | Going hungry lowers Spirit and makes checks harder. Taking "Oscar's" food draws a needle. |
| **The morning after** | Water, aspirin and curtains for Mom; sweep the broken glass; get the bottles out before Oscar sees them | Mom stays in bed longer and wakes up meaner; Oscar sees too much |
| **Mom's confidences** | Late at night she treats you as her best friend: her "dates," money, Bruce, her regrets. Listen \[Heart\], steer it away \[Sight check\], or leave \[Nerve\]. | Listening drains Spirit and lifts Mom's mood. Leaving leaves her hurt and cold, and leaves you guilty. |
| **The mess** | Dishes, ashtrays, empties, laundry; the old chore data, now visible mess props | Needles get sharper and more frequent |
| **Damage control** | After a bad night: clean up, get Oscar to bed, stay out of Bruce's sight | Oscar's trust, Spirit |
| **Bills and water** | The jar, the fridge calendar, the power bill (the well pump is electric: no power means no water) | A shutoff, then no showers. Townies notice, and so does Disclosure. |
| **The phone line** | One landline. Mom's calls come first; dial-up (eBay) and calling for help need it free. | A missed eBay listing; in a crisis, no line |

**Bruce's territory:** the barn workshop, his recliner, his guitar and his tools are off limits. He refuses all help ("you wouldn't understand it"). Getting caught in his space on a bad night is the most dangerous thing in the house, so evening movement becomes light stealth: know where Bruce is.

#### 5.6.2 Needles: the family as a bully system

**Everyone at home criticizes everything you do.** Any action at home, and sometimes just walking into a room, can draw a **needle**: a short, sharp line from Mom, Bruce or Oscar. Each one is a quick exchange, answered by one of your voices:

| Response | Voice | Effect |
| --- | --- | --- |
| **Take it** ("Sorry, I'll redo it") | Heart | Smooths things over. Spirit takes the hit, and your shadow grows if you take it too often. |
| **Talk back** | Nerve | Less Spirit loss now, but it can escalate (Bruce is dangerous to escalate with) |
| **Tune out**, keep working | Grit | Blocks most of the damage; overuse grows numbness (Grit's shadow) |
| **See what's under it** | Sight | On a passed check you see the real reason ("She's scared about money"), which takes almost no damage and gives insight |

| Who | Style | Typical needle |
| --- | --- | --- |
| **Mom** | Golden child and scapegoat: Oscar gets her care and praise, you get her blame. Hot and cold, praise that turns into blame. | "You're the only one who gets me. So why can't you do one thing right?" |
| **Bruce** | Contempt; treats you as beneath him | "Don't touch that. Go do whatever it is you do." |
| **Oscar** | Mockery, telling on you, breaking or taking your things (including your ritual space) | "Mom! They're doing the witch thing again!" |

**The rule that matters:** how often needles come depends on the critic's state (hangover, money, mood), not on how well you did. Unmet needs give them more ammunition, but doing everything right never makes it stop. Players learn what the teen has to learn: it isn't your fault.

### 5.7 Family meters

- **Mom's mood (built):** 0 to 100 with tiers from Warm to Mean. Lifted by a clean house, Oscar being happy, you listening to her, and Bruce being away. Dropped by mess, talking back, and Bruce being around. A **random drinking model (5.15)** sets which mornings she's hungover or passed out.
- **Oscar:** two values. **Wellbeing** (fed, safe, on track) and **Trust** (whether he turns to you). He bullies you whatever his trust is; what trust changes is whether he comes to you when things get bad.
- **Bruce:** a Stance from cold to hostile (set by the calendar's branch points), plus temper and mess. Home some days, away at gigs on others.

### 5.8 The ranch: clearing, salvage and three crops

**This is the game's farm.** In Stardew you clear debris, plant seeds, tend them over days and harvest. Here you **clear the junk and the hoard** for salvage, then turn that salvage into things that grow over days. Those are the three "crops": **workbench repairs, jam, and herbs**. Mornings belong to the ranch, since it's summer and there's no school. The build's `School` system is removed (10.1).

#### 5.8.1 Clearing the ranch

Decades of junk surround the house, and Bruce's late parents' hoard fills the garage and attic. Clearing works like Stardew's debris: each zone has piles to sort. Every pile turns into **trash** (bagged to the roadside for a dump run), **cans and bottles** (money), **scrap metal** (sold by the pound at the dump), **salvage** (inputs for crops and Pine Grove), or a **find** (eBay, history, a ghost clue).

| Zone | What's there | Clearing it gives | Opens |
| --- | --- | --- | --- |
| **The lean-to** (first goal, week 1) | Rotten boxes over an old workbench | Basic tools | **Your workbench** |
| **Front yard** | Tires, bottles, a dead washing machine | Cans, scrap, tires (planters) | The herb bed; the trampoline |
| **Car graveyard** | Three rusted cars, appliances | Scrap metal, bike and radio parts | Bigger repairs |
| **Creek bank** | Dumped junk in a blackberry thicket | Salvaged jars, scrap | **The berry patch**; a quiet spot (Spirit) |
| **Garage hoard** (Bruce's) | Boxes of his parents' things | Antiques, broken treasures, repair "seeds" | Big eBay value, at a risk (5.8.3) |
| **Attic** (Bruce's) | Letters, photos, his father's records | History and clues | The Bruce "crack"; ghost tokens |
| **The barn** | Bruce's workshop | Off limits | — |

**Tools are found or fixed, never bought:** gloves and bags at first, then a wheelbarrow (fixed at the workbench) that doubles each haul, a socket set and a glue clamp from the hoard, and a soldering iron from the car graveyard. Every tool speeds up clearing and repairs, like Stardew's tool upgrades.

#### 5.8.2 The three crops

| Crop | Planting | Tending | Harvest | Rhythm |
| --- | --- | --- | --- | --- |
| **Workbench repairs** (main crop) | Put a broken salvage item on the bench | One step a day: strip, glue (dries overnight), sand, paint, rewire. A skipped day slows it; a Grit check can save a day. | Sell it (eBay, Pine Grove guests, the jam stand), furnish Pine Grove (Revival), keep it for your room (Spirit), or give it to Oscar (trust) | 1–7 days per item, all summer |
| **Blackberry jam** | Pick berries (2 hours at Pine Grove or the creek) | Cook a batch in the kitchen in the evening, when Mom isn't using it for Oscar (expect needles), in salvaged jars. It sets overnight. | Six jars a batch: the stand, the lodge kitchen, guests | July–August only |
| **Witch's herbs** | Cuttings from Lilith (rosemary, sage, lavender, mugwort) in tire planters and salvaged pots | Water every morning. In a power outage the well pump stops, so you have to haul water. | Every 3–5 days: ritual ingredients (rituals need herbs), and bundles to sell to Dot's bingo crowd or the restored bathhouse | All summer |

**Example repairs:**

| Item | Found in | Days | Best use |
| --- | --- | --- | --- |
| Lamp, wooden chair | Front yard, garage | 1–3 | Furnish Pine Grove cabins (Revival) |
| Transistor radio | Car graveyard | 2 | Your room: music (Spirit), or eBay ($15) |
| Cast iron, Pyrex (just cleaning) | Garage hoard | 1 | eBay ($20–40); a Sight check spots the valuable ones |
| **A bicycle** | Car graveyard parts | 4 | **Independence:** faster trips to Pine Grove and, slowly, to town without Mom's ride (a whole afternoon, on the highway shoulder) |
| Oscar's broken skateboard | Oscar's room | 2 | Give it to Oscar: a big trust boost |
| Lodge jukebox | Pine Grove (hauled to the ranch) | 7 | Restores the lodge stage (June's area) |

**Every morning has something to check:** the herbs, the repair at its current step, a batch of jam setting, and a zone half cleared. That's the "one more day" pull, built from salvage.

#### 5.8.3 Bruce's hoard

Outside junk is fair game; Bruce calls it "crap." **The garage and attic are his parents' things, and therefore his.**

- **Taking from the hoard** is a Nerve gamble. A passive Sight check shows how likely he is to notice: "He counts those records."
- **Selling it on eBay** is theft, with big money and big shadow (Nerve's shadow grows).
- **If he notices:** he rages, searches your room (5.10.2), and confiscates your workbench tools for days.
- **Reading the attic letters** (no taking) is safe if you aren't seen. It's how you learn who Bruce was before the money ran out, and it can unlock his one crack.

Ghost tokens can turn up in the hoard. Bruce's family has been in the county for generations, and his parents kept everything: a 1911 Pine Grove springs brochure, a 1974 steam-field newspaper clipping, and so on.

### 5.9 Therapy (weekly, required)

Friday afternoons, at the therapist's office in Cobble Creek. It's court-ordered as part of the custody change, and Mom has to drive you. After a drinking night she may not, and a missed session means no lock-in that week, a call from the court, and a furious Mom. Therapy:

- **Settles the week:** raw voice points lock in, and the teen can **reframe** one event (5.3.1).
- **Locks in settling ghosts** (5.3.3).
- **Restores a lot of Spirit** and lowers shadows.
- **Sharing:** the player chooses how much to tell about home. Each honest share raises Disclosure (5.16).
- **Confidentiality, honestly:** in the first session the therapist explains, in plain words, that what you say stays private unless someone is in danger. Then they have to report it. The player always knows the stakes of sharing.
- **Encourages the witchcraft** as healthy self-expression, and from week 3 points you to **Alateen**: Tuesday evenings in a Cobble Creek church basement, for teens with a family member who drinks.

### 5.10 Economy

**Dollars, with poverty as pressure. The household runs on a coffee-can jar on the fridge, and the fridge calendar shows every bill before it's due.** The adults bring in little and spend it on drinking. The teen is expected to make up the difference, and every way of handling money costs something.

**Where the household money comes from:**

- **Mom:** a small, irregular income from sex work. It's never shown. She leaves for "dates" and comes back with cash on the counter. When she's flush, she puts a little in the jar and spends more, and drinking pressure jumps (5.15).
- **Bruce:** guitar tips and the occasional car job. He keeps what he makes and treats his work as too important to be bothered with a kid.

#### 5.10.1 How the teen earns

| Source | Where | When | How it works | Pay (tuning) |
| --- | --- | --- | --- | --- |
| **Pine Grove job board** | Pine Grove (on foot) | All summer | Short jobs (5.13.2). Take the wage, or donate it to the resort fund. | $5–15 a shift |
| **Blackberries** | Creek banks and roadsides | From early July | Pick wild blackberries (thorns: a Grit task). Sell them to the lodge kitchen, or at a weekend stand at the highway turnout. Jam made with Lilith sells for more. | $2–4 a basket; jam $5 a jar |
| **eBay reselling** | Finds anywhere; sold at home | All summer | Find items at the dump, in Pine Grove's junk rooms and lost-and-found, or at the thrift store. Sight spots what's valuable ("collectors want that Pyrex"). Photograph with your disposable camera, develop the film in town, list on dial-up at night when the phone line is free, wait for the 7-day auction, then ship from the post office. | $3–60 per item, after a delay |
| **Cans and bottles** | Home, Pine Grove | All summer | Sack the empties (Mom and Bruce's drinking keeps the supply coming) and redeem them at the **dump's recycling center**. | $3–6 a sack |

**Rides:** Pine Grove is a walk or bike ride through the woods. **Cobble Creek (the dump, store, post office, film developing, Alateen, therapy) needs Mom's car.**

- **Fridays:** Mom drives you to therapy, if she's able.
- **Any other day:** you have to ask, and her answer depends on her mood, her hangover, and whether you'll "keep me company." Rides cost emotional labor.
- **With Disclosure 30 or more,** Benny sometimes gives you a lift when he drives to town (5.16).

#### 5.10.2 The jar, and what holding back costs

Every Saturday the jar needs its share (about $60 for groceries, and the teen's share grows each phase), plus whatever bill is due. Every choice hurts:

| Choice | Upside | Cost |
| --- | --- | --- |
| **Pay into the jar** | Groceries happen; a moment of approval | Jar money can vanish on a drinking night. Paying in doesn't stop the needles. |
| **Hold back** (pay less) | Money for yourself, the resort or Oscar | A daily needle: "freeloader," "after everything I do for you" |
| **Hide money** in your room | Safe until someone searches | **Searches** come after drinking nights, when money is tight, or when Oscar tells on you. If they find it: the money is taken, you're called a thief, you're **grounded** (2–3 days with no Pine Grove), rides stop for a week, and your ritual space is searched and items confiscated. Sight warns you when a search is coming and finds better hiding places, but nowhere is ever fully safe. |
| **Pay a bill directly** in town | The money can't be stolen | Needs Mom's ride, and she sees it: "You think you're better than me?" Mom's mood crashes. |

**Money out:** the jar, the power bill, film developing and postage, stand supplies, ritual items, Pine Grove supplies (or donations), and things for Oscar.

### 5.11 Movement, interaction, menus, saving

- **Movement:** WASD, 4 directions, walk. A bike speeds travel between areas.
- **Interact:** E on people and objects. Seats open choice menus (eat, read, listen to Mom).
- **HUD:** day, clock and calendar (top right), Body, Spirit, money, prompts, a speech box with portrait. Ghost lines appear in a distinct style.
- **Backpack:** kept for tokens, ritual items and food. Farming tools removed; clearing tools (gloves, wheelbarrow, socket set) are found or fixed (5.8.1).
- **Saving:** autosave each morning; one slot.

### 5.12 Teen development research → mechanics

| Research theme | Where it lives in play |
| --- | --- |
| Sleep shift (needs 8–10 h, later melatonin) | Late-night trade-offs; all-nighters cost tomorrow's Morning |
| Identity search | Ghosts and rituals: choosing what to take in |
| Metacognition, self-reflection | Therapy sessions; ghost voices commenting on your choices |
| Autonomy vs. boundaries | Sneaking out, refusing requests, talking back |
| Peer orientation | Resort friends compete with family for your hours |
| Value formation | Each ghost's gift and cost; gray dialogue choices |
| Mood fluctuation, risk-taking | Low Spirit unlocks impulsive options and coping habits |
| Self-esteem vulnerability | Spirit; what Mom and Oscar say about you |

Puberty, sexual maturation and body changes stay out of the mechanics. The player character is a minor.

### 5.13 Saving Pine Grove

**Pine Grove is restored project by project, like Stardew's Community Center bundles.** Each project needs materials, hands and sometimes money. Every finished project visibly changes the resort, raises **Revival**, opens new jobs and activities, and moves the story of that area's ghost forward.

The buyout meeting on day 84 compares Revival (0 to 100) against two thresholds. At 60 or more Pine Grove is saved. From 30 to 59 it's partly saved: sold, but one restored area is protected. Under 30 it's lost. These are starting numbers for tuning.

#### 5.13.1 What restoration takes

| Ingredient | How you get it |
| --- | --- |
| **Salvage**: lumber, hardware (nails, hinges, pipe), fixtures (lamps, chairs, signs) | Search Pine Grove's junk piles, collapsed cabins and storage sheds (free, takes hours); dump runs (needs Mom's ride); townies' donations (a Heart check) |
| **Supplies**: paint, chlorine, glass, wiring | Bought with the **resort fund** |
| **Hands** | Your hours, plus helpers: Lilith, resort kids, Kevin, recruited townies (each helper speeds a project) |
| **The resort fund** | Event takings (Fourth of July, movie night, the fair weekend), the snack shack, donated wages, eBay sales of junk the resort can't use |
| **Voice checks** (some projects) | Grit to rebuild, Sight to find the hidden part, Heart to win over a donor, Nerve to salvage somewhere you shouldn't (Mayacamas's fenced lot) |

**Example projects:**

| Area (ghost) | Projects in order | Opens |
| --- | --- | --- |
| Bathhouse (Elsie) | Clear the debris → fix the plumbing → retile → reopen the warm spring pool | Pool scrubbing job; guests; Elsie's grave plot |
| Lodge (June) | Clean the great room → rewire the lights → restore the stage → reopen the kitchen | Kitchen jobs; berry pies; events and movie night |
| Workers' cabins (Ray) | Patch the roofs → rebuild the porches → furnish them for summer renters | Cabin cleaning job; renters (fund income) |
| Staff cabins and trail (Tracy) | Clear the trail as a firebreak → fix the pool deck → rebuild the snack shack | Snack shack job; pool parties; the turnout cross |

**Revival also comes from** bringing people back (each regular who returns), laying ghosts to rest, and the fund total. The tension stays the same: laying a ghost to rest heals its area, but you give up that voice's growth.

#### 5.13.2 The job board

Each job is a 2-hour shift. Take the wage, or **donate it to the resort fund** (Revival goes up, your money doesn't).

| Job | Unlocks | Pay (tuning) | Voice |
| --- | --- | --- | --- |
| Clear brush for fire safety | From day 6 (urgent in fire season) | $8 | Grit |
| Scrub the bathhouse and pool | From day 6 | $6 | Grit |
| Sort the lost-and-found and junk rooms | From day 6 | Keep one item to sell on eBay | Sight |
| Pick blackberries for the lodge's pies | July and August | Per basket | Grit |
| Hand out event flyers in Cobble Creek | Before each event (needs a ride) | $5, and brings people back | Heart |
| Set up and tear down events | Event days | $10 | Grit |
| Dish duty on guest weekends | Kitchen restored | $10 | Heart |
| Clean cabins after renters | Cabins restored | $8 | Grit |
| Run the snack shack by the pool | Snack shack restored | $5 plus tips | Heart or Nerve |

#### 5.13.3 Bingo night

**Every summer evening, Benny calls bingo in the lodge** for locals and vacationers: card tables, Dot's pie by the slice, folding chairs, the ceiling fans. On every B the whole room shouts **"B for what? B for BENNY!"**

- **It's an evening choice:** bingo means missing dinner at home, which brings needles, and Oscar might be left with a drinking Mom.
- **It gives:** Spirit, small prizes (sometimes useful ones), and townies to meet. Each regular you befriend can come back to Pine Grove (Revival) and raises Disclosure if they see enough.
- **Bingo nights are where the community feels real:** the buyout gossip, the ghost stories, and Benny and Dot at their best.

### 5.14 Hobbies

Four 2000s hobbies, each a healthy way to cope that restores Spirit and ties into another system:

| Hobby | Where | What it does | Ties to |
| --- | --- | --- | --- |
| **Burning mix CDs** | The family computer | Make mixes as gifts. Each mix sets a mood. | Relationships: a mix for Oscar raises his trust; a mix for Lilith says what you can't |
| **Disposable camera** | Anywhere, mostly the resort | Take photos. Developed prints sometimes show a ghost (or a smudge). | Ghost discovery, Discovery aesthetic, the resort journal |
| **Handheld games** | Your room, anywhere | A quick escape: a lot of Spirit in a short time. | Sharing it with Oscar is a bonding beat; too much counts as isolating (5.5) |
| **MySpace, AIM and Neopets** | The family computer, at Night | Chat with resort kids; away messages show your mood. (Lilith prefers the notebook.) | Resort friendships; a private outlet when the house is loud. Ties up the phone line, which Mom hates. |

### 5.15 Drinking nights: the unpredictability model

**Drinking nights are random, but not fair: they cluster, they lull you into calm, and the signs are there if you've learned to read them.** That's the experience children of alcoholics describe: unpredictability, then hypervigilance. The model combines three known game techniques:

- **A rising hazard** (like the "pseudo-random distribution" in Warcraft III and Dota 2): each sober day makes the next drinking night more likely. Calm stretches feel safe, and that's when they break.
- **Clustering** (a simple Markov chain): one drinking night raises the odds of another the next day. Binges happen.
- **A pacing director** (like Left 4 Dead's AI Director): guardrails keep drama from stacking up and keep each phase near its target.

**Each evening:**

```
pressure += 4 per sober day
          + money stress (jar short, bill due)   +5 to +10
          + a Mom–Bruce fight today             +8
          + Friday or Saturday                  +5
          + Mom comes home with cash +8
          − a calm day (house clean, jar full, Oscar happy)  up to −5
chance  = phase base + pressure / 200
          × 1.5 if last night was a drinking night (binge)
          × 0.3 during a "promise" (see below)
roll    → drinking night? if yes: pressure −= 30
```

- **Phase base:** weeks 1–2 = 3%, weeks 3–5 = 12%, weeks 6–8 = 25%, weeks 9–11 = 40%.
- **The director's guardrails:**
  - It never overrides a scripted beat; crisis night is fixed.
  - At most 3 nights in a row.
  - Each phase's weekly average stays within its target: about 0, 1, 2 and 3 or more nights a week.
- **Promises:** after a very bad night, Mom swears she's done. Drinking almost stops for 5 to 10 random days, then rebounds. Players will believe her, as kids do.
- **What kind of night:** Fun (Mom loving and silly; confusing warmth), Sad, Mean or Frightening. The roll depends on Mom's mood, Bruce's stance and money.
- **The player can't control it.** Everything the teen does can shift pressure by only about ±20%. That's Al-Anon and Alateen's "three Cs": I didn't cause it, I can't control it, and I can't cure it. Players discover it by trying.
- **Reading the signs (Sight):** on days with high odds, warning signs appear in the house: bottles in the recycling, a paper bag in Bruce's truck, Mom humming too brightly, cash gone from the jar. Higher Sight shows more and truer signs, and with Sight 4 or more the teen can warn Oscar or hide the jar money in time.

Sources, checked October 29, 2026: [pseudo-random distribution](https://liquipedia.net/dota2/Random_Distribution) (it began in Warcraft III; each failed roll raises the next chance, then resets), [Left 4 Dead's Director](https://developer.valvesoftware.com/wiki/Left_4_Dead_2/Scripting/Director_Scripts) (build-up, sustained peak and relax phases), and [Al-Anon's three Cs](https://al-anon.org/blog/al-anons-three-cs/).

### 5.16 When someone steps in: Disclosure

**Disclosure is a hidden 0 to 100 track of how much the adults around the teen know.**

- **Raised by:** honest shares in therapy (the most), telling a trusted townie, neighbors seeing things, Alateen, and a police pickup after a full breakdown (+25 in one go, 5.2.4).
- **Lowered by:** covering for Mom, lying to the therapist, and refusing help.

| Disclosure | What happens | What it costs |
| --- | --- | --- |
| **0–29: no one** | The family closes ranks. After the crisis the teen handles everything alone, as June did. | Spirit drains faster in weeks 11–12; the epilogue says "nobody knew" |
| **30–59: more time away** | The adults around you quietly make room. Benny and Dot save you a seat at bingo, let you stay late, and give you lifts to town. Lilith's parents are almost never home, so weekend sleepovers at her place (away from drinking nights) are easy, as long as you can get there. In practice, more of your hours are spent outside the house. | Mom resents "those people" and starts needling about where you've been |
| **60+: a social worker** | The therapist must report. A county social worker schedules a **home visit** (week 9, or right after the crisis). Before it, Mom cleans the house and coaches you on what to say, and Bruce sits in. **Afterward, life at home gets worse** whatever happens: you're grounded, your room is searched, needles double, rides stop, and Mom says "you tried to take my kids." | See the visit's outcomes below |

**The home visit (one red check, with Heart or Nerve; Sight reads the social worker):**

- **Tell the truth, and it lands:** a case is opened with a safety plan and monthly check-ins. Home is harsher for the rest of the summer, but on crisis night you have a number that works, which makes the "stop it" outcome easier. The epilogue notes that a record exists.
- **Tell the truth, and it doesn't land:** Mom's performance wins and the case is closed as "unfounded." You get the retaliation without the protection. Disclosure drops to the middle tier, but the therapist still believes you.
- **Cover for Mom:** the case is closed with less retaliation. Disclosure drops, and Reliance and shadows rise from the lie.

There is no placement outcome: Mom's family in Redding is estranged and isn't an option.

*California's mandated-reporter rules and the home-visit process are summarized from memory. Check them before writing the scene, and consider a review by someone who works in child welfare.*

## 6. Graphics & audio

### 6.1 Visual system

2D top-down pixel art on a 16 px tile grid. Godot 4.7, GL Compatibility renderer, integer scaling. Base art comes from the LimeZu Modern series on itch.io (already in `art_library/limezu`). Custom sprites cover characters, ghosts and key props.

**Art rules:**

- **The house tells the story.** Clutter, bottles, ashtrays and an empty fridge change through the summer.
- **Ghosts look like their era.** Each is drawn in a faded, desaturated palette with a soft shimmer and period clothes (1910s, 1950s, 1970s, 1980s) so they read as "other" at a glance.
- **The resort is faded glamour:** peeling paint, a drained pool, a lodge with a dusty stage, pine needles over everything.
- **Camera:** follows the player with smoothing, clamped to room bounds (`player_camera.gd`).
- **Time of day:** each part of the day has its own tint. Night has a cool, quiet palette.
- **License check:** confirm the LimeZu license covers a commercial release and Matt's edits.

### 6.2 Interface

Framed panels in the shared `ui_theme.tres`. Minimal HUD: day, clock and calendar; Spirit and Body; money; prompts; speech box with portrait. **Ghost voices** get their own text style (italic, faded color, a small era icon), like Disco Elysium's skill lines. A **ritual screen** and a **ghost journal** show who you've drawn, who's settling and who's internalized.

### 6.3 Audio

- **Music:** lo-fi acoustic and indie-folk for days. At the resort, warped old records from the ghosts' eras: 1910s parlor piano, 1950s radio ballads, 1970s country AM, 1980s cassette pop. Sparse ambient pads at night.
- **Audio look & feel:** warm and nostalgic, with dread underneath. On drinking nights the music drops out, leaving the TV through the wall, ice in a glass, a door. Ghosts arrive with a faint period song bleeding in.
- **SFX priorities:** home sounds (dishes, fridge hum, screen door), resort ambience (pool splashes, wind in the pines, cicadas), ritual sounds (match strike, candle, pages).
- **Voice:** none. Text only.

## 7. Story & narrative

### 7.1 Backstory

Mom and Dad divorced. The teen and Oscar lived with Dad, seeing Mom on scheduled weekends. Dad's own addiction cost him custody of both kids. He couldn't hold on, so he writes a goodbye letter to the teen, and the kids move in with Mom. She has just married Bruce, and the two of them bought a cheap, run-down ranch outside Cobble Creek. The teen arrives already used to taking care of things, hoping, finally, for stability.

### 7.2 Main plot

The summer starts warm. Mom is happy, the ranch is new, and Pine Grove is a sun-faded wonderland where the teen makes friends. The resort is about to be bought out. At the same time Mom and Bruce drink more, the money runs out, and Oscar takes his anger out on the one person who can't leave.

At the resort the ghosts begin to appear, each a person who once faced a version of the teen's choices. With a friend's spellbook and a therapist who listens, the teen starts building a self out of them. In mid-August, on a red-flag night, a drunk parent tries to drive Oscar down the mountain grade, and everything the teen has become is tested. By the end of summer the resort's fate is decided, the family has a reckoning, and the teen walks into their future as whoever they chose to become.

### 7.3 Plot progression

Progress is driven by the **calendar** (scripted beats on fixed days), **flags** (choices and requests) and **ghost stories** (each ghost has 3 to 4 story beats that unlock as you spend time with them). Story beats land through gameplay changes first, like an empty fridge, a locked door, or Mom asleep on the couch at noon, and only then in dialogue.

### 7.4 Cutscenes

No cinematic cutscenes. Short in-engine scenes using the Dialogue Manager addon (already installed). Big beats happen at dinner, at night and at the fade between days. Dad's letter is the opening scene.

### 7.5 Endings

**The ending is about sorrow and loss. Ten years later, in the summer of 2016, the teen (now about 24) comes back to Cobble Creek after years of longing for home. Most things are the same, but the feeling of home is gone.** Four slides (Self, Oscar, the family, Pine Grove), each in one of 3 states, lead into a final scene at the Pine Grove pool. The states change what the teen carries back, never the feeling: every version is a homecoming that doesn't come home.

**How it plays:** each slide is a still illustration with a short narration in the adult teen's voice (about 120–150 words), voiced by the teen's strongest voice. The 12 slides combine into 81 summers.

#### 7.5.1 Slide 1: Who you became

| State | Conditions (checked in order) | 2016 | What's lost |
| --- | --- | --- | --- |
| **Steady** | Reliance under 30, at most one voice in shadow form, and at least one ghost whose truth you learned (internalized or laid to rest) | Working, renting a small place, still writing in a notebook. Has a therapist of their own. Can say "I'm not okay" out loud. | Doesn't go home for holidays. Steadiness came from leaving. |
| **Guarded** | Everything else | Capable, independent, the one everyone calls in a crisis. Never asks anyone for anything. | Close to no one. The calm in a crisis never switched off. |
| **Shadowed** | Reliance 60 or more, or 3 or more voices in shadow form, or 3 or more breakdowns in the last two weeks | Drinking more than they admit, or not getting out of bed. The family's pattern, carried forward. | Almost everything, but Eli's card is still in their wallet. The slide ends on that door. |

#### 7.5.2 Slide 2: Oscar

| State | Conditions | 2016 | What's lost |
| --- | --- | --- | --- |
| **He turned to you** | Trust 70 or more, and you were there on the crisis night ("stop it" or "go with them") | 23, working, calls you every week, still steals your hoodies. "He calls you first now." | He forgave you for Dad; he never forgave Mom. |
| **At war, but safe** | Trust 40–69 | You talk at holidays and argue. He's okay, and he doesn't know what you did that summer. | The brother you could have had. |
| **Becoming Bruce** | Trust under 40, or you weren't there on the crisis night | He drinks like Bruce and talks like him. The last call between you ended in shouting. | Him, for now. The slide's last line leaves room: "He still has the skateboard." (only if you fixed it) |

#### 7.5.3 Slide 3: The family

| State | Conditions | 2016 | What's lost |
| --- | --- | --- | --- |
| **Someone saw** | Disclosure 60 or more and the home visit's truth landed, or you stopped the crisis night and called for help | A record exists. Mom went to treatment twice and still drinks, less. She's angry at you and calls anyway. | Mom's trust in you. The summer is the thing nobody in the family talks about. |
| **Same house** | Disclosure 30–59, or the truth didn't land | Nothing changed until you left at 18. Mom calls on your birthday, sometimes the right day. | The years you stayed. |
| **Nobody knew** | Disclosure under 30 | You left without a word. The ranch looks the same from the road. | Any version where someone helped. |

**Bruce's line:** Hostile Bruce left after the crisis night, and Mom blames you. Cold Bruce is still in the recliner. If you saw his one crack, the slide adds that you still have the song in your head.

#### 7.5.4 Slide 4: Pine Grove

| State | Conditions | 2016 | What's lost |
| --- | --- | --- | --- |
| **Saved** | Revival 60 or more | Still open. Kevin runs it now. Bingo still runs every summer night, and someone else calls it. | Benny and Dot are gone. A bench by the pool reads "B for Benny." |
| **Partly saved** | Revival 30–59 | Sold to Mayacamas. The area you restored most (the pool or the staff cabins) was kept as a community space. | The rest is steam wells behind a fence. |
| **Lost** | Revival under 30 | Steam wells, a chain-link fence, and the old sign rusting in the brush. | All of it. |

**Ghosts on this slide:** a ghost you laid to rest is gone, and their area is at peace. An internalized ghost is still with you. In the shadowed ending, the shadows are here too.

#### 7.5.5 The final scene: the pool

A short, quiet playable scene, the game's last. Summer 2016, evening. The adult teen drives back up the grade they never stopped thinking about.

- **The drive in:** the same turnouts, the same store, the same smell of pines and sulfur. The burned ridge from the 2015 fire is still black in places, with new houses where old ones stood (see below).
- **The walk:** past the ranch from the road (they don't stop), then the woods trail to Pine Grove. Familiar things trigger memories: the trampoline frame, the jar's coffee can in a yard sale box, the bingo call drifting from somewhere.
- **The pool:** open and full of strangers' kids (saved), the one place the fence didn't take (partly saved), or drained, behind chain-link you climb (lost). Either way, nobody knows your name.
- **Oscar:** sitting on the edge with his feet in the water (turned to you), arriving late and awkward (at war), or not there, with a voicemail you don't play (becoming Bruce). Even at best, you talk like people who used to live together.
- **Lilith:** she moved away years ago. A postcard in your pocket if the friendship stayed strong; nothing if it didn't.
- **Ghosts:** internalized ghosts sit on the far side of the water, quieter now, the only ones who feel the same. Laid-to-rest ghosts aren't there. In the shadowed ending, the shadows stand at the fence.
- **The last line** comes from your strongest voice, something like: "It all looks the same. That's the hardest part." Then the screen fades on the water. The longing doesn't resolve; the game ends on it.

**The 2015 fire, lightly.** In reality, the 2015 Valley Fire burned much of Cobb, destroying 1,955 structures and resorts like Hoberg's and Harbin Hot Springs ([Valley Fire](https://en.wikipedia.org/wiki/Valley_Fire)). The epilogue mentions it only lightly: a blackened ridge on the drive in, rebuilt houses, one line of narration. It isn't a plot event. It echoes the fire season of 2006 and the game's theme: the mountain keeps repeating what people don't learn from. No real victims, places or details are depicted.

### 7.6 Sensitive content

Alcohol use, verbal and emotional abuse, and parentification are central, and the game **shows them directly** (Mature). Rules for writing these scenes:

- Show the harm and its aftermath honestly. Never play abuse for laughs and never make it a reward.
- No physical or sexual violence against the children on screen. The fear comes from anticipation, sound and aftermath.
- The player always has a coping action (leave the room, go to Oscar, call a friend, lock the bedroom door) even when it can't fix anything.

**Teen coping habits (5.5):** show them as relief that turns into a trap. Never reward them with upgrades or humor. Always leave a path back through friends, therapy and rituals.

**Witchcraft:** portray it respectfully as a teen's real practice and self-expression, not as a horror trope or a joke.

**Mom's sex work:** implied, never shown. The teen's exposure is emotional: Mom's oversharing, strangers' trucks in the drive, cash on the counter, the phone. There is never sexual content involving or around the teen or Oscar. Write it with the same care as the drinking: it shows Mom's desperation and isolation, and it's never a joke or titillation.

Required: a content warning on launch, an options toggle that softens or skips the harshest scenes, a helpline and resources screen (reachable from the pause menu and the credits), and an outside reader with lived experience of these themes.

## 8. Characters

### 8.1 The player ("the teen")

- **Backstory:** see 7.1. The eldest child, raised by an addicted father to be self-sufficient.
- **Personality (starting voice):** independent, constantly worried about others. Quick to anger over small things, eerily calm in a real crisis. That calm is a sign of parentification, not a strength the game celebrates. Ghosts and habits reshape this voice over the summer.
- **Appearance:** set in a light character creator (skin, hair, outfit palette; pronouns).
- **Activities (instead of stats):**

| Activity | Where | Ties to |
| --- | --- | --- |
| Reading | Couch, bed, library | Sight or Heart; ritual recipes |
| Rituals | Your room, at Night | Ghosts, Spirit |
| Cooking | Kitchen | Oscar's wellbeing, Mom's mood (built) |
| Odd jobs, restoration | Resort, Cobble Creek | Money, saving Pine Grove |
| Trampoline | Yard | Spirit |
| 2000s hobbies | Varies | Spirit, friends: burning mix CDs, a handheld game, disposable-camera photos, MySpace and AIM (5.14) |

### 8.2 Family

| Character | Role | Core tension |
| --- | --- | --- |
| **Doris (Mom)** | The parent you live with now | Loving and fun on good days, cruel on bad ones, and her criticism is constant. She earns a small, irregular income from sex work. It's never shown, but she half-hides it and half-overshares about it. She treats the teen as her best and only friend, telling them far too much about her dates, money and Bruce. Oscar is her baby: she cooks, cleans and cares for him, unless she's too drunk to, and then it falls to the teen. She doesn't take care of the teen at all. Happiest when Oscar is happy; mocks Bruce behind his back. Estranged from her family in Redding, which leaves her isolated and ashamed. |
| **Bruce** | Mom's new husband | Eccentric and contemptuous. He inherited some money when his parents died in his 20s, and it's nearly gone. He repairs cars and plays guitar, considers both far too skilled to be "bothered with a kid," and won't let the teen help with anything or touch his things. Neither pays much, and money is the core of his fights with Mom. Messy, smokes, drinks with her. Truly loves Doris in his way. His arc runs from **cold** (dismissive, ignores you) to **hostile** (rages, takes money, the danger on crisis night), with **one crack**: a rare night when you hear him playing his late father's guitar alone, and he lets you listen to one song before he shuts the door. |
| **Oscar** | Younger brother | About a year younger. Lives with you, bullies you, and is Mom's golden child. Terrified that Mom will leave too. Full arc in 8.2.1. |
| **Dad** | Lost custody to his addiction | Appears only in the opening letter: simple, sweet, saying goodbye. His addiction foreshadows the teen's dark path. |

#### 8.2.1 Oscar's arc

**Oscar is about a year younger than the teen: close enough to compete, old enough to be cruel, and still a kid who's terrified Mom will leave too.** His bullying is a survival strategy he learned at home. His arc is whether he turns to the teen before the Fourth of July, or follows Bruce.

|  |  |
| --- | --- |
| **Who he is** | About 13 to the teen's 14 (exact ages open). Mom's golden child. Sharp-tongued, a tattletale, quick to take your things, and starting to talk like Bruce. Funny when he forgets to be mean. |
| **Why he bullies** | **He learned it.** Mom and Bruce talk to the teen that way, and Mom laughs when Oscar does it too ("at least he's honest"). **Golden-child pressure:** staying Mom's favorite means someone else has to be the bad one. **He misses Dad,** and he blames the teen for the end of life at Dad's. |
| **What he fears** | **That Mom will leave too.** Dad's gone. Every "date," every night Mom doesn't come home on time, he panics, and that's when his cruelty spikes. |
| **What trust changes** | Trust never stops the bullying. It changes where he goes when things get bad: to you, or to hide, or to Bruce's side. At high trust he warns you about searches, comes to your door on drinking nights, and calls for you on the crisis night. |
| **Care he needs** | Mom cooks and cleans for him. When she can't, you make sure he eats, gets home, and isn't out alone at night. He won't thank you; he'll tell Mom you burned the eggs. |

**Proposed backstory secret:** the night custody ended, it was the teen who called for help when Dad passed out. Oscar was asleep, and all he knows is that "they took us away because of you." A fever dream shows the teen what really happened, and in week 3 or 4 the teen can choose to tell Oscar. It ties straight into the Disclosure theme: telling the truth saved them, and cost them everything. *(Proposed; change it if it doesn't fit your story.)*

**Trust: small daily acts (0 to 100, starting at 30):**

| Raises trust | Lowers trust |
| --- | --- |
| Feeding him when Mom can't | Lashing out at him (a coping habit, a big drop) |
| Fixing his broken skateboard (a big boost) | Telling on him to Mom |
| Sharing the Game Boy | Leaving him alone on a drinking night |
| Standing between him and Bruce (risky; a big boost) | Choosing Lilith's or bingo on a bad night (small) |
| Not telling on him back | Taking "his" food |
| A protection ritual for him (if he finds out, it can go either way) | Mocking him back in front of Mom |

**Four key beats (v1.0, one a week):**

| Week | Beat | The choice |
| --- | --- | --- |
| 1 (day 3) | **The TV fight.** He picks a fight over the TV, the first needle. Afterward, a Sight passive check: he's at the window, watching the driveway for Mom's car. | Fight back \[Nerve\], let it go \[Heart\], or notice him at the window \[Sight\], which reveals his fear early |
| 2 (first "date" night) | **"Is she coming back?"** Mom is out late and hasn't called. Oscar won't sleep, picks a fight, then asks it. | Reassure him \[Heart\], tell him the truth \[Nerve\], or tell him to go to bed |
| 3 | **The calling card.** The store calls you, not Mom: Oscar tried to shoplift a prepaid calling card to call Dad. On the walk home he says, "You're the reason we can't see him." | Cover for him (trust up; risky if Mom finds out), tell Mom (trust drops; Mom briefly on your side), or make him return it with you \[Heart or Nerve check\]. If you've seen the fever dream, you can tell him the truth. |
| 4 (the Fourth of July) | **The car.** After the fireworks, a drunk Mom wants to drive "home" down the grade. Oscar goes toward the car because he's scared she'll leave without him. | High trust: he comes to find you first, which opens the "stop it" outcome. Low trust: he's already in the car. |

**Oscar's epilogue slide (3 states):**

- **He turned to you** (trust high, wellbeing okay): "He still steals your stuff. But he calls you first now."
- **Still at war, but safe** (middle): the fights go on; he's okay, and he doesn't know what you did.
- **Becoming Bruce** (trust low, or hurt on crisis night): he's learned the house's lessons too well.

He never dies (as with the crisis night).

### 8.3 Supporting characters

| Character | Where | Role |
| --- | --- | --- |
| **Eli Brightwater** (the therapist) | Office in Cobble Creek | Elias "Eli" Brightwater, late 60s, a retired high-school English teacher who became a counselor. **The first kind man in the teen's life.** He talks gently and slowly, never raises his voice, and lets silences sit. His office above the hardware store has a bird feeder at the window and a shelf of mythology and folklore. He's the first adult to ask about *your* interests (witchcraft, your repairs, what's on your MySpace) and remember them next week. He's honest about his limits: he must report danger, and he can't fix your home. He can only be there. At first the teen doesn't trust him (Nerve options), and trusting him is earned. He's what a safe man looks like, set against Dad and Bruce. |
| **Lilith** | Her double-wide out of town; Pine Grove | Real name Danielle; "Lilith" is the nickname you gave each other (she gives the player theirs too, which is how she signs the notebook). Your age, goth and moody like you, funny, rebellious and spoiled: she gets anything she asks for except attention. Her parents are almost never home, off on motorcycle trips and their own adventures, and she hates them. She lives in a **double-wide on a big piece of land** with her horse **Ola** and her **tarantulas**. She never comes to your house (you won't let her see the chaos), so **getting to hers is always your problem**: a long walk, the bike, or begging Mom for a ride. You mostly talk through a **notebook you pass back and forth**. She's your first crush, and the love is unrequited. She's neglected from the other direction: too much freedom and nobody watching. |
| **Benny and Dot** | Pine Grove | A sweet old couple whose family has run Pine Grove for generations. **Benny** grew up there. As a boy he remembers the night the old lodge burned (June, 1958) and the steam workers in the cabins (Ray, 1974). He runs the job board, fixes what his knees allow, and **calls bingo every summer night at the lodge**. On every B, the room shouts "B for what? B for BENNY!" **Dot** runs the snack bar and the kitchen, bakes the pies, and knows everyone's business kindly. They can't keep up the work anymore, and their kids moved to the city. The steam company's offer would pay for their retirement and Dot's medical bills, so they're torn, not villains. The teen isn't fighting them; the teen is giving them a reason to hold on. |
| **Resort regulars (2–3)** | Pine Grove | Summer kids and odd adults; friendships and activities. |
| **Cobble Creek townies (2–3)** | Cobble Creek | Store clerk, librarian, a bartender who serves Mom and Bruce. They half-see what's happening. Some help if you let them. |

**Real people, renamed:** Benny and Dot are inspired by the real couple who ran the real Pine Grove resort near Cobb. Their names and identifying details are changed because the game invents tragedies on the land. Lilith is based on a real friend; her in-game given name (Danielle) is invented.

### 8.4 Ghosts

#### 8.4.1 Rules for every ghost

**Every ghost is unreliable.** Each wants something from the teen, and each tells their own story in a way that serves that want. The truth comes out in pieces: their own slips, the resort's records, photos, and townies' memories.

- **An agenda:** what the ghost wants the teen to do. It always sounds like help.
- **A lie:** the central untruth in how they tell their story. Exposing it is the ghost's last beat.
- **A tell:** a verbal habit that shows up when they're lying, for players who pay attention.
- **A family echo:** a loose resemblance to someone at home that the game never states.
- **Drawn by:** the choices that make the ghost approach.
- **Two endings for each ghost:**
  - **Internalized:** you take in their gift and cost, lie and all.
  - **Laid to rest:** you confront their lie, finish their business, and heal their part of Pine Grove. You lose their path.
- Once the lie is exposed, an internalized ghost's voice becomes **more honest**, and its cost softens a little. Knowing someone's truth changes how you carry them.

**Tone varies by ghost:** the springs girl is eerie and childlike, the steam worker warm and tired, the caretaker's wife faded and sad, the girl on the grade sharp and cool.

#### 8.4.2 The shared mystery: "What the Mountain Keeps"

**All four ghosts lived at Pine Grove in different eras, and each was trapped there: by illness, poverty, isolation or family.** The ground under the resort is volcanic and always warm. Hot springs, steam vents and sulfur creeks are part of every scene. The mountain seems to keep the people who can't get out.

**Real lore we draw on (fictional people only):**

- **Springs and "the cure" (1870s–1920s):** Lake County's springs drew city people to "take the cure" in rustic campgrounds and cabins. Highland Springs was advertised as "an excellent place for consumptives" (people with tuberculosis) ([Highland Springs](https://en.wikipedia.org/wiki/Highland_Springs,_Lake_County,_California); [Springs of Lake County](https://en.wikipedia.org/wiki/Springs_of_Lake_County,_California)).
- **The Geysers:** the steam field in the Mayacamas Mountains. A resort owner lit his resort with geothermal power in 1921. PG&E's Unit 1 produced the nation's first commercial geothermal electricity in 1960, and by the mid-1980s it was the world's largest geothermal field ([The Geysers](https://en.wikipedia.org/wiki/The_Geysers); [ASME landmark #109](https://www.asme.org/about-asme/engineering-history/landmarks/109-geysers-unit-1)). Ray's blowout is invented; no source documents a specific accident.
- **Winter isolation:** resorts closed for the season, leaving caretaker families alone, snowed in on mountain roads.
- **The real Pine Grove:** on Bottle Rock Road in Cobb. It began as a **campground in the late 1800s**. Its spring-fed pool was **built in 1923** with water from the property's own spring, and it has about 24 cabins, a main house and an event center. It was **recently listed for sale** as a legacy business with over 100 years of history, which echoes the game's buyout ([LoopNet listing](https://www.loopnet.com/Listing/15960-Bottle-Rock-Rd-Cobb-CA/39149825/); [Pine Grove Cobb](https://www.pinegrovecobb.com/); [sale site](https://www.pinegrovesale.com/)).
- **The mountain grade:** the steep, winding highway over Mount St. Helena toward Calistoga and the Napa Valley, the route everyone takes to "get out."
- **Fire season:** dry summers, red-flag days, smoke on the horizon. The 2006 summer has a fire threat on the ridge.

*Checked by web search on October 29, 2026. The sources are listing and summary pages, not primary history, so confirm with the Lake County Historical Society before writing in-game text. The nightly bingo comes from the designer's own memory.*

| Era | Pine Grove was | Ghost | How they were trapped | How they died |
| --- | --- | --- | --- | --- |
| 1911 | A summer campground where city families came for mountain air and spring water, consumptives among them | The girl at the springs | Illness, and a family that left her | Tuberculosis, alone on a sleeping porch |
| 1958 | Closed every winter, with one caretaker family | The caretaker's wife | Isolation, snow, a drinking husband | Set fire to herself in the lodge, which burned |
| 1974 | Cheap off-season housing for steam-field workers | The steam worker | Poverty: double shifts to feed his family | A steam-well blowout at The Geysers |
| 1989 | A fading summer resort with teen staff | The girl on the grade | Her family | Went off the mountain grade at night, trying to get to the Napa Valley |

**Two readings, never resolved (pillar 4):**

- **Supernatural:** the hot ground keeps the ones who can't escape. Fever, fire, steam, and a road that won't let you leave.
- **Grounded:** a poor, remote mountain county with no doctors, no money, no way out, and neighbors who look away.

**The buyout (revised):** the buyer is **Mayacamas Steam & Power** (fictional), which wants Pine Grove's land for new steam wells. It's the same company whose unsafe well killed the steam worker in 1974. His story uncovers the company's old safety records, and exposing them is a major way to raise Revival and stop the sale.

**The climax (revised, proposed):** in weeks 9 to 11, on a drinking night during a fire-season red-flag warning, Mom or Bruce tries to drive Oscar down the mountain grade drunk. Every ghost echoes in that moment: the child left behind, the provider who pays any cost, despair, and the road. Whatever the teen has become (ghosts, Spirit, Reliance, Oscar's trust) decides how that night goes. Breaking the pattern is the teen's real act of growing up.

#### 8.4.3 The girl at the springs: Elsie Marlowe (1911)

**Eerie and childlike.** A 9-year-old from San Francisco, sent to Pine Grove's campground for the mountain-air "cure" for consumption. She coughs into a handkerchief and plays jacks by the spring. In 1923 the pool was built over that spring, so now she haunts the pool and its bathhouse. She's the first ghost most players meet, and the one who seems to see everything.

|  |  |
| --- | --- |
| **Path** | The Seer / Witch: wonder and second sight, at the price of being alone |
| **Agenda** | Wants a playmate who never leaves. She pulls the teen away from people and toward her, the rituals and the quiet. |
| **Her lie** | "Mama's coming back on Sunday. She promised. Cross my heart." |
| **The truth** | Her family paid for one summer, checked out in August, and stopped answering. The staff moved her to a sleeping porch, away from guests. She died there in November, alone, and was buried in the resort's overgrown plot. Her letters home came back unopened. |
| **Tell** | "Cross my heart." When pressed, she changes the subject to a game. |
| **Family echo (loose)** | Oscar: the little kid the adults leave behind |
| **Drawn by** | The first ritual; staying in your room; choosing rituals over people; caring for Mom when she's sick or hungover |
| **Gift** | Stronger rituals; hears the other ghosts more clearly; sees through adults' lies (insight options: "She's not coming back tonight.") |
| **Cost** | Isolation: friend and family options cool; adults think you're strange |
| **Resort area** | The spring-fed pool (built 1923), its bathhouse, and the old tent-cabin platforms |
| **Laid to rest by** | Finding her returned letters in the bathhouse office, uncovering her grave marker in the overgrown plot, and leaving her a gift (her doll, or a photo you took) so someone finally came back |

**Voice:** *"You can hear the water talking under the floor. Nobody else listens. Stay and play. They won't notice you're gone."*

**Story beats:**

1. **Approach:** after your first ritual, a girl's cough echoes in the empty bathhouse, and jacks are laid out on the steps.
2. **Confidant:** she teaches you to "listen to the water" (your first true ritual) and says her mama is coming Sunday.
3. **Crack:** the 1911 register shows her family checking out in August. A bundle of letters in the office is stamped "Return to Sender."
4. **Truth:** she admits no one came. It lands hard if you've been left too, or if you've left Oscar alone. Internalize her (sight, plus her warning about isolation) or lay her to rest at her grave.

#### 8.4.4 The steam worker: Ray Delacruz (1974)

**Warm and tired.** A 34-year-old steam-field hand for Mayacamas Steam & Power. He lived with his wife and three kids in Pine Grove's off-season workers' cabins. He's in work boots and a hard hat, smells of sulfur, cracks dad jokes, and is always checking his watch for the next shift.

|  |  |
| --- | --- |
| **Path** | The Caretaker / Provider: holding everyone up, whatever it costs you |
| **Agenda** | Wants the teen to keep working and keep providing, and never stop. He never tells you to rest, because he never did. |
| **His lie** | "Nobody's fault. Accidents happen up there. And my family was fine. I made sure of that." |
| **The truth** | The company knew that well's casing was failing and put him on it during a double shift anyway. His wife had begged him to quit doubles, and his kids barely saw him. When the well blew out, the steam and heat killed him before anyone could reach him. The company paid his family a small settlement and kept the safety memo buried. |
| **Tell** | Talks in dollar figures and hours ("time and a half, that's thirty more for groceries"). "That's just the job." |
| **Family echo (loose)** | Bruce, who can't make his money stretch, and the teen, who carries the house |
| **Drawn by** | Taking odd jobs to pay for groceries; covering a bill; caretaking Mom; putting someone else first several times in one week |
| **Gift** | Jobs pay more; housework costs less; protecting and feeding Oscar works better |
| **Cost** | Your own needs come last; Spirit recovers slower; hard to refuse requests |
| **Resort area** | The workers' cabins and the steam vents along the creek |
| **Laid to rest by** | Finding his last pay envelope and the 1974 safety memo hidden in his cabin, then bringing the envelope to his grown son, **Danny**, who runs the Cobble Creek gas station and never knew what his father said about him |

**Voice:** *"Hey, kiddo. Bills don't care if you're tired. One more shift and we're square. Then we rest. Then."*

**Story beats:**

1. **Approach:** after a week of paying for groceries yourself, a man in a hard hat is sitting on a workers' cabin porch, steam drifting behind him.
2. **Confidant:** he teaches you to stretch a dollar, and tells you his family never went without.
3. **Crack:** Danny, at the gas station, says his dad was "never home" and that his mom worked herself sick after the settlement. The safety memo is under the cabin floor.
4. **Truth:** he admits he was always gone and that the job killed him. It's the moment the game says out loud that you can't carry everyone, and that it isn't your fault. Internalize him (now able to let you rest) or lay him to rest by bringing Danny the envelope. Then decide whether to make the memo public (5.13).

**Content note:** his death is shown only through aftermath (the closed well, the memorial plaque, Danny's memories), never on screen.

#### 8.4.5 The caretaker's wife: June Halvorsen (1958)

**Glamorous and sad, faded.** A 31-year-old who married the resort's winter caretaker and spent every November to April snowed in at the closed lodge with him and his bottle. She wears a good dress no one sees and keeps the place spotless. The town still tells kids the ghost story of "Crazy June."

|  |  |
| --- | --- |
| **Path** | The Drowned: despair and the slide into coping habits |
| **Agenda** | Wants company in the dark. She draws the teen to stay in, close the curtains, sleep through the day, and "rest," which really means giving up. |
| **Her lie** | "I was happy here, honey. It was the stove, an accident." And: "Nobody can help you up here. Don't bother asking." |
| **The truth** | She did ask. She wrote to her sister in Sacramento, the doctor and the pastor, but her husband took the car keys and the mail, and the letters never left. The few people who saw her that winter called her strange and kept away. In February she set fire to herself in the lodge, and the old lodge burned. |
| **Tell** | Talks about how lovely the snow was. Hums. Straightens things when the subject gets close. |
| **Family echo (loose)** | Mom: warmth and despair in the same breath, trapped with a man who drinks |
| **Drawn by** | Low Spirit at Night; staying in bed; isolating; a first sip of Bruce's beer; caretaking Mom after a drinking night |
| **Gift** | Empathy: reads moods, knows when to go quiet, defuses Mom and Bruce; mood-reading dialogue options |
| **Cost** | Coping habits are offered more and feel better (Reliance rises faster); when Spirit drops, it drops deeper |
| **Resort area** | The rebuilt lodge and the burned foundation of the old wing behind it |
| **Laid to rest by** | Finding her unsent letters in the old wing's chimney, mailing them to her sister's family (who write back), and telling the true story at a resort event so "Crazy June" becomes June again |

**Voice:** *"Shh. Close the curtains, honey. Nothing out there is coming for you. Isn't it nice when it's quiet?"*

**Story beats:**

1. **Approach:** on a low-Spirit night, the lodge lights are on although the resort is closed, and a woman in a good dress is dusting.
2. **Confidant:** she's tender, and she teaches you how to keep the peace at home. She says she was happy.
3. **Crack:** a Cobble Creek townie tells the "Crazy June" story. In the chimney you find a bundle of stamped, unmailed letters asking for help.
4. **Truth:** she admits she asked and no one came, and she asks you to keep asking. This is the game's most direct moment about despair, and it's written carefully. Internalize her (empathy, with her warning built in) or lay her to rest by mailing the letters.

**Content note:** her death is suicide. Never show it. Use aftermath and her letters only. Show a resources screen after beat 4. Wanting company in the dark is a warning sign the game teaches the player to notice, and her truth is the reverse of her lie: ask for help, and keep asking.

#### 8.4.6 The girl on the grade: Tracy Lindgren (1989)

**Sharp and cool.** A 17-year-old Cobble Creek girl working summer staff at Pine Grove, with a Walkman, a scrunchie and a packed bag under her bunk. Her home was loud and cruel. One August night she took the family car and drove the mountain grade toward Yountville, where a friend had promised her a room and a job. She never made the bottom of the hill. She's the ghost closest to the teen's age.

|  |  |
| --- | --- |
| **Path** | The Escapee: freedom, nerve, getting out |
| **Agenda** | Wants the teen to leave: take the keys, take the bus, forget Oscar, and finish the drive she never finished. |
| **Her lie** | "Nobody would've missed me. I was almost free. Trust me, it's worth it." |
| **The truth** | Her little brother **Kevin**, then 8, waited at the window every night for a year. He's now Pine Grove's quiet handyman, and he still won't drive the grade. |
| **Tell** | "Trust me." Counts miles and minutes ("forty minutes to the valley floor"). |
| **Family echo (loose)** | Dad, who left, and the teen's own temptation to leave Oscar |
| **Drawn by** | Sneaking out; refusing requests; a big fight with Mom; looking at bus schedules or car keys |
| **Gift** | Nerve: sneaking out, freedom and defiance options; reads danger fast (warns you before a drinking night turns bad) |
| **Cost** | Distance from Oscar and Mom: their trust and mood drift down, and leaving starts to look like the only answer |
| **Resort area** | The staff cabins, plus her faded roadside cross at a turnout on the grade |
| **Laid to rest by** | Finding her packed bag and mixtape in the staff-cabin wall, restoring her roadside cross, and giving the tape to Kevin |

**Voice:** *"Your mom's out by nine. Keys are on the hook. Forty minutes and you're somewhere else. Trust me."*

**Story beats:**

1. **Approach:** the first night you sneak out, a girl with a Walkman is sitting on the staff-cabin steps, jingling car keys.
2. **Confidant:** she's thrilling. She teaches you to sneak out clean and talks about the valley as if she lived there.
3. **Crack:** your disposable-camera photo of the grade turnout shows a faded cross with her name. Kevin flinches when you mention her.
4. **Truth:** she admits someone did miss her, and that she never got anywhere. It lands hardest if you've been planning to leave Oscar. Internalize her (nerve, plus her warning) or lay her to rest by giving Kevin the tape.

**Inspired by a real event: handle with care.** Tracy's story draws on a real fatal crash on a Northern California mountain road. Everything identifying is invented: her name, the year (moved from 2005 to 1989), her family, the car, and the exact place and circumstances. Don't use details from news coverage that could let locals recognize the real people. Show the crash only through aftermath (the cross, Kevin, the turnout), and keep her death unconnected to drinking, which belongs to the 2006 climax. If anyone close to the real event might play the game, consider asking them first.

### 8.5 "Enemies"

There's no combat. The antagonists are **pressure, not people:** the developer buying Pine Grove (faceless, met through letters and a meeting), poverty, addiction, and time.

## 9. Game world & locations

### 9.1 Look & feel of the world

Sun-bleached and a little neglected everywhere. The ranch is big and run down. Cobble Creek is a few blocks of practical storefronts where everyone knows a little about everyone. Pine Grove is faded glamour in the pines, half-closed and full of echoes. At night all three feel different.

### 9.2 Locations

| Location | Status in build | Purpose | Connection to plot |
| --- | --- | --- | --- |
| Ranch: inside (downstairs) | Built | Kitchen, living room, bathroom, halls; needs, cooking, caretaking | Where parentification happens |
| Ranch: teen's room | Partly (bed, desk) | Sleep, ritual space, hobbies | The one space that's yours |
| Ranch: yard, barn, stable | Built (shells) | Trampoline, scrap, firewood, sneaking out | Its decay mirrors the family's |
| Cobble Creek: town | Not built (current "Pine Grove" map could become it) | Store, library, post office, dump, therapist's office, Alateen, bar | The witness: who sees, who helps |
| Pine Grove: resort | Not built | Lodge, two spring-fed pools, cabins, bathhouse, stage, bingo | Escape, friends, ghosts, the buyout |
| Lilith's place | Not built | A double-wide on open acreage: Ola's paddock, the tarantula tanks, a field for rituals. A long walk or bike ride from the ranch. | Freedom with nobody watching; sleepovers away from drinking nights; the crush |
| The woods trail and the creek | Not built | The walk between the ranch and Pine Grove; blackberries, a quiet spot, the walk-home sequence | Escape route; where the shadows line the path |
| The mountain grade | Not built | The highway turnout with Tracy's cross; a few scenes only | Tracy's story; the crisis night |

### 9.3 Tutorial (week 1)

**Week 1 is the tutorial**, taught through the story:

1. **Day 1 (Mon, Jun 12):** Dad's letter. Arrive at the ranch. Mom shows you the house (movement, E, doors). Unpack. Dinner.
2. **Days 2–3:** the first house read, the first visible need and request (household), and Oscar's first fight (Spirit).
3. **Day 4:** errand to Cobble Creek; meet Lilith.
4. **Day 5 (Fri):** first therapy session.
5. **Day 6:** first trip to Pine Grove and the first glimpse of a ghost.

The full week is in the Summer calendar tab.

### 9.4 Optional areas (later)

A video rental store in Cobble Creek, a Clear Lake day trip, and the county fair on a fixed late-summer date. (The woods trail and the creek are now core areas.)

## 10. Build status & roadmap

**About half of the current code carries over. The time and energy core has to be reworked, and the ghost system is new.** That's normal at this stage: the prototype proved the engine and data patterns, and the design has now found its identity.

### 10.1 What happens to each system (Godot 4.7, about 5,500 lines of GDScript)

| System | Verdict | What changes |
| --- | --- | --- |
| Data-driven `.tres` catalogs, `EventBus`, `GameState`, save/load | Keep | Add ghost, Spirit, Body, Reliance, Burnout, Disclosure, Revival, Bruce's stance, Oscar and crop fields to the save |
| Mom's mood (`Mom`) | Keep | Add the random drinking model (5.15) and condition roll |
| Quests (`QuestSystem`) | Keep | Reuse for requests and ghost story beats |
| Cooking, fridge, seats | Keep | Cooking feeds Oscar |
| Interactables, doors, rooms, NPC talk, HUD shell | Keep | HUD swaps Gas for Spirit and Body, and the real-time tick for an action-driven clock |
| `GameClock` real-time minutes | Rework | Turn off the real-time tick; every action calls advance(); fixed anchors at dinner, night and bedtime |
| Gas (`GameState.gas`, overnight roll) | Replace | Spirit meter |
| `ChoreSystem` weekday checklist | Rework | Visible needs tied to mess props, plus requests |
| Farming: tools, soil, seeds (`ranch.gd`, `Enum.Tool`) | Rework | Remove seeds and watering. Repurpose the tool-on-tile code in `ranch.gd` for clearing junk piles, and reuse `Crate` (sorting a pile), `MessProp` (visible mess) and `ItemPickup` (salvage and finds) for the ranch (5.8). |
| "Pine Grove" map | Rework | Becomes Cobble Creek; Pine Grove resort is a new map |
| Ghosts, rituals, therapy, coping habits, Oscar meters | New | See Section 5 |
| Dialogue Manager addon | Use | Story scenes and ghost voices |
| Project name `stardewclone` | Rename | Rename to Pine Grove (title chosen) |
| Homeschool (School autoload, subjects, grades, answer key) | Cut | It's summer. Remove the autoload, the subject data and the schoolwork chore; keep reading as a seat activity. |
| Body meter, hallucinations, walk home, sick day, Burnout | New | 5.2; the walk home reuses the real maps with a shader for distortion |
| Ranch clearing, workbench, jam, herbs | New (reuses ranch.gd, Crate, MessProp, ItemPickup, Cooking) | 5.8 |
| Needles, the jar, searches, income sources | New | 5.6, 5.10 |
| The family computer (eBay, MySpace, mix CDs) and Lilith's notebook | New | Menu-driven screens; the phone line is shared state |
| Restoration projects, job board, bingo | New (reuses QuestSystem) | 5.13 |

### 10.2 Roadmap

1. **M4: Core rework.** The clock moves only on actions, Spirit and Body replace Gas, needs and requests replace the checklist, farming becomes ranch clearing and the three crops. *Goal: the current house plays as one week of the new loop.*
2. **M5: Vertical slice, week 1.** Dad's letter, the week-1 tutorial (calendar tab), the lean-to and the first workbench repair, therapy once, Lilith and the notebook, needles, the jar, Cobble Creek as a map, a small first piece of the resort, **one ghost through its full lifecycle** (drawn → ritual → therapy → internalized voice), one drinking night, one coping habit. *Goal: a stranger plays it and can say what the game is about.*
3. **M6: Ghost system.** All 4 ghosts' data and stories, ghost journal, ritual screen, the 3-ghost limit, gifts and costs, shadows and hallucinations.
4. **M7: Pine Grove and Cobble Creek.** Full resort, restoration and buyout, friendships, the witness thread.
5. **M8: Full summer content.** 12-week beat calendar, ghost stories, endings and epilogue.
6. **M9: Polish.** Title screen, character creator, options, audio, content warnings, playtesting, balance.

### 10.3 Practice notes

- **Prototype the ghost loop first, on paper or in a throwaway scene,** before building it properly. It's the riskiest and most original system.
- **Playtest the slice early** with 3 to 5 people outside the team. Watch, don't explain. Ask what they felt (aesthetics) before what they think of systems.
- **Keep this GDD short and current.** Update it when a playtest changes a decision, and add to the decision log in Section 0.
- **Scope guard:** any new feature names the pillar and aesthetic it serves, or it goes on a "later" list.

## 11. Scope & production plan

**v1.0 is a 4-week summer, 3–5 hours long, with 2 ghosts, built by one developer at 10–20 hours a week. It ships as a free demo in about 9 months and a full Steam release in about 2 years.** The 12-week, 4-ghost design in this doc stays as the long-term vision; anything outside v1.0 goes on the "Later" list (11.4).

### 11.1 Constraints

| Constraint | Reality | What it means |
| --- | --- | --- |
| Team | Solo developer; Matt helps with art or writing occasionally | Plan as if Matt isn't available; anything he does is a bonus |
| Time | 10–20 hrs/week (plan on 15, about 65 a month and 700 a year) | About 1,350 hours to v1.0 (11.3) |
| Engine and art | Godot 4.7; LimeZu Modern packs for tiles and props | Custom art is limited to characters, portraits and ghosts |
| Writing | The heaviest cost in this genre | A word budget (11.3) and data-driven text (needles, voice lines) |
| Money | Self-funded | Steam's fee is $100 per game, recouped after $1,000 in sales ([Steamworks: app fee](https://partner.steamgames.com/doc/gettingstarted/appfee)) |

### 11.2 Release plan

| Release | What it is | Where | Target |
| --- | --- | --- | --- |
| **Demo** | Week 1 (the tutorial week), about 60–90 minutes, ending on Mom's "just one glass" | itch.io (free) and Steam as a demo | About August 2027 |
| **Steam page** | "Coming soon" page with wishlists, 5 screenshots and a short trailer | Steam | As early as possible, about spring 2027 |
| **Steam Next Fest** | A demo showcase that runs three times a year ([Steamworks: upcoming events](https://partner.steamgames.com/doc/marketing/upcoming_events)) | Steam | October 2027 edition (check the dates and registration deadline) |
| **v1.0** | The 4-week summer, 3–5 hours | Steam (Windows, plus Mac and Linux via Godot export); about $10–15 | About fall 2028 |
| **Later** | The full 12-week vision: Ray and June, more weeks | An update or a follow-up | After v1.0, if it does well |

### 11.3 Budget

**Hours by milestone (at about 65 hrs/month):**

| Milestone | Contents | Hours | Months |
| --- | --- | --- | --- |
| M4 Core rework | The action clock, Spirit and Body, needles, the jar, ranch clearing and the workbench in the existing house and ranch | 150 | Nov 2026 – Jan 2027 |
| M5 Demo | Week 1 content, Pine Grove (first area), Cobble Creek (one street), the first ghost encounter, Lilith, Eli, the tutorial, menus, save | 400 | Feb – Aug 2027 |
| M6 Weeks 2–4 | Two ghost stories, drinking model, therapy and reframes, hallucinations, the walk home, sick day, Pine Grove restoration, Disclosure | 500 | Sep 2027 – Apr 2028 |
| M7 Finish | Crisis night, epilogue, audio, content warnings, accessibility, playtests, balance, store assets | 300 | May – Sep 2028 |
| **Total** |  | **about 1,350** | **about 23 months** |

These are estimates for planning. Solo projects usually run 25–50% over, which is why the cut list (11.4) exists.

**Writing budget (about 36,000 words, a short novel):**

| Content | Amount | Words |
| --- | --- | --- |
| Family and story scenes | About 16 scenes | 9,600 |
| Ghost stories (Elsie, Tracy) | 4 beats each plus voice lines | 6,500 |
| Inner-voice lines (4 voices) | About 60 lines each | 4,000 |
| Therapy sessions | 4 sessions | 3,200 |
| Lilith's notebook replies | About 20 | 2,400 |
| Needles | About 150 short lines, as data with variants | 2,000 |
| Epilogue slides | 12 | 1,800 |
| Fever dreams | 4 | 1,600 |
| Shadow confrontations | About 8 | 1,200 |
| Items, jobs, eBay listings, UI |  | 4,000 |

**Custom art budget:** about 10 character sprite sets (the teen in 3–4 presets, Mom, Bruce, Oscar, Lilith, Eli, Benny, Dot, Kevin), about 10 portraits, 2 ghosts plus their shadow versions, and the hallucination effects. Everything else comes from the LimeZu packs.

### 11.4 What's in v1.0, and what waits

| System | v1.0 | Later |
| --- | --- | --- |
| Summer | 4 weeks, June 12 – July 9, 2006 (11.5) | The 12-week calendar (Summer calendar tab) |
| Inner voices | All four, as plain inner voices | — |
| Ghosts | **Elsie and Tracy**, full stories; a voice at **level 2** draws its ghost | Ray and June (Grit and Heart get faces), the steam memo, the Mayacamas subplot |
| Meters | Spirit, Body, hallucinations, the walk home, sick day, police pickup | Burnout tiers, growth spurts |
| Home | Needles, needs, the jar, searches, Bruce's territory and his one crack | — |
| Ranch | 4 zones (lean-to, front yard, car graveyard, garage hoard); workbench (about 8 repairs, including the bike); herbs | The attic letters, more repairs, **jam** |
| Pine Grove | 2 restorable areas (the pool and bathhouse for Elsie, the staff cabins and snack shack for Tracy), the job board, nightly bingo in the lodge | The lodge stage, the workers' cabins, events beyond the Fourth of July |
| Money | Job board, cans at the dump, blackberries (sold fresh), eBay (simple) | Jam sales |
| People | Mom, Bruce, Oscar, Lilith, Eli, Benny, Dot, Kevin; one or two townies | Alateen, Danny, resort regulars, the bartender |
| Therapy and Disclosure | 4 Fridays with reframes; the 3 tiers; one social-worker scene if Disclosure is high | A longer case arc |
| Hobbies | Handheld games, the disposable camera, eBay | MySpace, AIM, Neopets, mix CDs |
| Character creator | Name, pronouns, 3–4 preset looks | A full creator |
| Endings | 4 slides × 3 states (12 slides) | — |
| Maps | Ranch and house (exist), woods trail, Pine Grove, Cobble Creek (one street), Lilith's place (small), the grade (one scene) | Clear Lake trip, the county fair |

**Cut if needed, in this order (first to go first):**

1. MySpace, AIM and Neopets
2. Mix CDs
3. Jam (if it's still in)
4. Alateen
5. Growth spurts and the Burnout tiers (keep the sick day)
6. The bike's trips to town (keep the bike for the trail)
7. The social-worker scene (keep the Disclosure tiers in text and the epilogue)
8. Lilith's place as a map (meet her at Pine Grove instead)
9. Tracy's full story (last resort: ship with one ghost)

**Never cut:** the house and needles, Oscar, the four voices, Elsie, Pine Grove restoration, Eli and therapy, the crisis night, and the epilogue. That's the game.

### 11.5 The 4-week summer (v1.0)

| Week | Dates | Phase | Key beats |
| --- | --- | --- | --- |
| 1 | Jun 12–18 | Honeymoon (**the demo**) | The tutorial week as written in the Summer calendar tab; one glass of wine on Sunday |
| 2 | Jun 19–25 | Cracks | Drinking starts; the first ghost (your strongest voice); the solstice ritual (Wed, Jun 21); a grocery shortfall |
| 3 | Jun 26 – Jul 2 | Parentified | Second ghost; the power shutoff notice; Bruce's branch point; Oscar is caught shoplifting; ghost truths come out |
| 4 | Jul 3–9 | Breaking point and resolution | **The Fourth of July (Tue, day 23): fireworks at Pine Grove and the crisis night** (red-flag fire danger, a drunk parent at the wheel); the aftermath; final therapy (Fri, Jul 7); **the buyout meeting (Sun, Jul 9, day 28)**; the epilogue |

Drinking odds compress to the 4 weeks: about 3%, 12%, 25% and 40%. Revival thresholds and money amounts get retuned for 28 days. The full 12-week plan stays in the Summer calendar tab as the long-term vision.

### 11.6 Working rules for a solo developer

- **Build the demo first, then decide.** Wishlists and playtest reactions from the demo decide how far v1.0 goes.
- **Placeholder first.** Gray boxes and LimeZu stand-ins until a system is fun; final art last.
- **One in, one out.** Any new feature replaces something already on the v1.0 list, or goes to "Later."
- **Write with data.** Needles, voice lines, jobs and eBay listings live in data files with variants, so one written line can serve many moments.
- **Monthly check-in.** Compare the hours spent with 11.3. If a milestone runs more than a month late, take the next item off the cut list.
- **Playtest every milestone** with 3–5 people outside your head. Watch; don't explain.
- **Keep a devlog** (short posts on itch.io or social media). It builds an audience for the Steam page and keeps you honest.
- **Protect yourself.** This game is about burnout and carrying too much; the same rules apply to the person making it. Plan on 15 hours a week, not 20, and take breaks between milestones.

Sources (checked October 30, 2026): [Steamworks: Steam Direct fee](https://partner.steamgames.com/doc/gettingstarted/appfee), [Steamworks: upcoming events and Next Fest](https://partner.steamgames.com/doc/marketing/upcoming_events).
