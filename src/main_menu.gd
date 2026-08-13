class_name MainMenu
extends Screen


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_quit"):
		get_tree().quit()


func _on_host_button_pressed() -> void:
	var game: Game = load("res://src/game.tscn").instantiate()
	_change_screen(game)
	game.host_server(7586)


func _on_join_button_pressed() -> void:
	var game: Game = load("res://src/game.tscn").instantiate()
	_change_screen(game)
	game.join_server("localhost", 7586)


func _on_play_local_button_pressed() -> void:
	var game: Game = load("res://src/game.tscn").instantiate()
	_change_screen(game)
	game.play_offline()
