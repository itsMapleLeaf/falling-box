class_name MainMenu
extends Screen


func _ready() -> void:
	%PlayButton.grab_focus()


func _on_play_local_button_pressed() -> void:
	ScreenManager.set_screen(load("uid://d2ms6aaidbi2r").instantiate())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_quit"):
		get_tree().quit()


func _on_host_button_pressed() -> void:
	var game: ServerGame = load("uid://bn41v7yeprjri").instantiate()
	_change_screen(game)
	game.host_server(7586)


func _on_join_button_pressed() -> void:
	var game: ServerGame = load("uid://bn41v7yeprjri").instantiate()
	_change_screen(game)
	game.join_server("localhost", 7586)


func _on_host_room_button_pressed() -> void:
	var game: NodeTunnelGame = load("uid://b7seloxwrkdli").instantiate()
	_change_screen(game)
	game.host_room()


func _on_join_room_button_pressed() -> void:
	var game: NodeTunnelGame = load("uid://b7seloxwrkdli").instantiate()
	_change_screen(game)
	game.join_room(%JoinRoomIdInput.text)
