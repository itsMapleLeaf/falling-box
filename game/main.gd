extends Node2D

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action("debug_exit"):
		get_tree().quit()
