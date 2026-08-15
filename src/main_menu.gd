class_name MainMenu
extends Screen


func _ready() -> void:
	%PlayButton.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_quit"):
		get_tree().quit()


func _on_play_button_pressed() -> void:
	ScreenManager.set_screen(Screens.local_game())


func _on_host_room_button_pressed() -> void:
	var game: NodeTunnelGame = Screens.node_tunnel_game()
	ScreenManager.set_screen(game)
	game.host_room()


func _on_join_room_button_pressed() -> void:
	%JoinRoomPrompt.show()


func _on_join_room_prompt_submit_button_pressed() -> void:
	var game: NodeTunnelGame = Screens.node_tunnel_game()
	ScreenManager.set_screen(game)
	game.join_room(%RoomIdInput.text)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
