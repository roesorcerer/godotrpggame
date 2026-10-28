class_name SubjectData
extends Resource

## One homeschool subject. Authored as a .tres in data/subjects/. Studying it
## for real grows its skill; copying the answers only raises its grade.

@export var id: StringName = &""
@export var display_name := ""

## The skill honest study grows (School.SKILL_NAMES has the display names).
@export var skill: StringName = &""

## What studying looks like, shown in the speech box afterwards.
@export_multiline var study_line := ""
