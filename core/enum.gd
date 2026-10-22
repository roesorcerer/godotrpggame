extends Node

enum Style {BASIC, PJS, FANCY}
enum State {DEFAULT, MOWING, BUILDING, SHOP}
enum Tool {AXE, SHOVEL, WATER, SEED} #needs to match teen chores
enum Machine {SPRINKLER, FISHER, SCARCROW, DELETE}
enum Seed {TOMATO, CARROT, DAFFODIL}
## How a quest is finished. QuestData.goal_target says who/where/which flag.
enum QuestGoal {TALK_TO, VISIT, FLAG}
## What kind of thing an item is (ItemData.category); sorting, selling, gifting.
enum ItemCategory {MISC, SEED, CROP, FORAGE, TOOL}

#Instead of seed maybe schoolwork?

#Item - what kinnds of items would be gathered in this game? 

# what kid of items would be bought in the shop? 
