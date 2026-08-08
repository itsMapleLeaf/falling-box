class_name Game
extends Screen


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_quit"):
		_change_screen(load("uid://i4jvedvwx3en").instantiate())


func host_server(port: int) -> void:
	pass


func join_server(host: String, port: int) -> void:
	pass
