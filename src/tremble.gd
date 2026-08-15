extends Node

@export var max_intensity := 50.0
@export var damping := 8.0

@export var intensity_tiny := 1.0
@export var intensity_minor := 2.5
@export var intensity_moderate := 8.0
@export var intensity_major := 20.0

var current_intensity := 0.0


func trigger(intensity: float) -> void:
	current_intensity = minf(current_intensity + intensity, max_intensity)


func _process(delta: float) -> void:
	current_intensity = lerpf(current_intensity, 0, clamp(delta * damping, 0, 1))
	#DebugUI.set_debug_value("tremor", "%0.3f" % current_intensity)
