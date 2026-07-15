## Implements custom rounded position smoothing,
## to remove awkward flickering gaps between objects caused
## by subpixel positioning
extends Camera2D

@export var target: Node2D
@export var position_internal := Vector2.ZERO
@export_range(1.0, 20.0, 0.1) var pan_speed := 10.0

func _ready() -> void:
	position_internal = target.global_position

func _process(delta: float) -> void:
	position_internal = (
		position_internal.lerp(target.position.round(), clampf(delta * pan_speed, 0, 1)).round()
	)
	offset = position_internal.round()
