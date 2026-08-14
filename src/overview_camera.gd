class_name OverviewCamera
extends Camera2D

const WINDOW_MARGIN = 100
const ZOOM_STIFFNESS = 7.0

@export var targets: Array[Node2D] = []


func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = 7.0
	limit_enabled = false
	offset = Vector2(0, -150)


func _process(delta: float) -> void:
	if targets.is_empty():
		return

	var top_left: Vector2
	var bottom_right: Vector2

	for target in targets:
		top_left = top_left.min(target.global_position) if top_left else target.global_position
		bottom_right = bottom_right.max(target.global_position) if bottom_right else target.global_position

	var window := get_viewport_rect().grow(-WINDOW_MARGIN)

	var window_scale := 1 / maxf(
		1,
		maxf(
			(bottom_right.x - top_left.x) / window.size.x,
			(bottom_right.y - top_left.y) / window.size.y,
		),
	)

	global_position = (top_left + bottom_right) / 2
	zoom = zoom.lerp(Vector2(window_scale, window_scale), delta * ZOOM_STIFFNESS)
