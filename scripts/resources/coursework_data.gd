class_name CourseworkData
extends Resource

## One assignment out of the monthly correspondence packet.

@export var id: StringName = &""
@export var subject: StringName = &""       ## math / english / science / civics
@export var title := ""
@export_multiline var flavor := ""

@export_range(5, 240, 5) var minutes := 90
@export_range(0, 30) var gas_cost := 4

## Progress awarded at full concentration. Scaled by CourseworkSystem.
@export_range(0.1, 5.0, 0.1) var work_units := 1.0

## Must be done in order within a subject.
@export var sequence := 0
