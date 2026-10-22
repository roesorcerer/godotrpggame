extends Control

## The half-circle on the clock panel: how much daylight is left. The lit
## wedge shrinks downward like a setting sun and shifts from sunny yellow to
## dusk red; once it's gone the whole face is night.

## When the light is fully gone (24h clock). The day starts at GameClock.START_HOUR.
@export_range(7, 24) var dusk_hour := 20

@export var sky := Gradient.new()
@export var night := Color(0.17, 0.18, 0.33)


func _init() -> void:
	# t = 0 is full daylight, t = 1 is the last light before dark.
	sky.offsets = PackedFloat32Array([0.0, 0.6, 0.85, 1.0])
	sky.colors = PackedColorArray([
		Color(1.0, 0.85, 0.29), Color(1.0, 0.68, 0.24),
		Color(0.93, 0.42, 0.3), Color(0.62, 0.3, 0.42)])


func _ready() -> void:
	EventBus.minute_ticked.connect(func(_m): queue_redraw())
	EventBus.day_started.connect(func(_d): queue_redraw())


func daylight_left() -> float:
	var daylight_minutes := float(dusk_hour - GameClock.START_HOUR) * 60.0
	return clampf(1.0 - GameClock.minutes / daylight_minutes, 0.0, 1.0)


func _draw() -> void:
	# The face is a half-ellipse bulging left from the middle of the right edge.
	var centre := Vector2(size.x, size.y / 2.0)
	var radius := Vector2(size.x, size.y / 2.0)
	draw_colored_polygon(_wedge(centre, radius, 0.0, 1.0), night)
	var left := daylight_left()
	if left > 0.0:
		draw_colored_polygon(_wedge(centre, radius, 1.0 - left, 1.0), sky.sample(1.0 - left))


## Wedge from t0 to t1, where t = 0 is the top of the face and t = 1 the bottom.
func _wedge(centre: Vector2, radius: Vector2, t0: float, t1: float) -> PackedVector2Array:
	var points := PackedVector2Array([centre])
	var steps := 24
	for i in steps + 1:
		var t := lerpf(t0, t1, float(i) / steps)
		var angle := -PI / 2.0 - t * PI     # top -> left -> bottom
		points.append(centre + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	return points
