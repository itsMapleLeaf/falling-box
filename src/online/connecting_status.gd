extends Control


func _process(_delta: float) -> void:
	var base_input := cos(
		# make every second a single cycle
		lerpf(0, TAU, Time.get_ticks_msec() / 1000.0),
	)

	# convert from -1:1 range to 0:1
	var normalized := inverse_lerp(0, 1, base_input)

	# convert the normalized input to the alpha range we want
	modulate.a = lerpf(0.4, 0.7, normalized)
