## Implements custom rounded position smoothing,
## to remove awkward flickering gaps between objects caused
## by subpixel positioning
extends Camera2D

@export var target: Node2D
@export_range(1.0, 20.0, 0.1) var pan_speed := 10.0

var target_position := Vector2.ZERO


func _ready() -> void:
	target_position = target.global_position


func _process(delta: float) -> void:
	target_position = (
			#target_position.lerp(target.position.round(), clampf(delta * pan_speed, 0, 1)).round()
			target.global_position
	)
	global_position = target_position.round()
