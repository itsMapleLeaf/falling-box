extends Node

const MAX_INTENSITY := 1000.0
const DAMPING := 8.0

var current_intensity := 0.0


func trigger(intensity: float) -> void:
	current_intensity = minf(current_intensity + intensity, MAX_INTENSITY)


func _process(delta: float) -> void:
	current_intensity = lerpf(current_intensity, 0, clamp(delta * DAMPING, 0, 1))
	DebugUI.set_debug_value("camera_shake", "%0.3f" % current_intensity)
