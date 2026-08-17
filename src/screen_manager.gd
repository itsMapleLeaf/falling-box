extends Node

var current_screen: Screen
var initial_title: String


func set_screen(new_screen: Screen) -> void:
	get_window().title = initial_title

	if current_screen:
		current_screen.queue_free()

	add_child(new_screen)
	current_screen = new_screen


func _ready() -> void:
	initial_title = get_window().title
