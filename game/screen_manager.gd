extends Node

var current_screen: Screen


func switch(new_screen: Screen) -> void:
	if current_screen:
		current_screen.exit_screen()
		current_screen.queue_free()

	current_screen = new_screen
	add_child(new_screen)
	current_screen.enter_screen()
