@tool
class_name Pulse
extends Node

## The number of pulse cycles per second
@export_range(0.1, 2, 0.1, "or_greater", "or_less") var speed := 1.0

@export_range(0, 1, 0.1) var min_alpha := 0.2
@export_range(0, 1, 0.1) var max_alpha := 1.0

@export var target: CanvasItem


func _process(_delta: float) -> void:
	if not target:
		return

	var base_input := cos(
		# make every second a single cycle
		lerpf(0, TAU, Time.get_ticks_msec() / 1000.0) * speed,
	)

	# convert from -1:1 range to 0:1
	var normalized := inverse_lerp(-1, 1, base_input)

	# use the normalized value as our delta between the upper and lower bound
	var output := lerpf(min_alpha, max_alpha, normalized)

	target.modulate.a = output
