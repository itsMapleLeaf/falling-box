class_name TrembleNode
extends Node

@export var target: Node2D
@export_range(1, 30, 1, "suffix:px") var stiffness: float = 5.0

@onready var camera := $Camera
@onready var real_position := target.global_position


func _process(delta: float) -> void:
	# interpolate smoothly to the target position,
	# but with a random offset added per-frame
	var tremble_offset := Vector2.from_angle(randf() * TAU) * Tremble.current_intensity

	real_position = real_position.lerp(target.global_position, clampf(delta * stiffness, 0, 1))

	camera.global_position = real_position + tremble_offset
