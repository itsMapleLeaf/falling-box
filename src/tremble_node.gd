class_name TrembleNode
extends Node2D


func _physics_process(_delta: float) -> void:
	position = Vector2.from_angle(randf() * TAU) * Tremble.current_intensity
	reset_physics_interpolation()
