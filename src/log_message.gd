extends Label


func _on_expiration_timer_timeout() -> void:
	var fade_out := create_tween()
	fade_out.tween_property(self, "modulate:a", 0, 1)
	fade_out.play()
	await fade_out.finished
	queue_free()
