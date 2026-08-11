extends Node2D

@onready var debug_label: Label = %DebugLabel


func _physics_process(delta: float) -> void:
	position = Vector2.from_angle(randf() * TAU) * Tremble.current_intensity
	reset_physics_interpolation()
