class_name ScreenManager
extends Node

var screen: Screen
var initial_title: String


func set_screen(new_screen: Screen) -> void:
	if screen:
		screen.queue_free()

	get_window().title = initial_title

	screen = new_screen
	screen.screen_changed.connect(set_screen)
	add_sibling(screen)


func _ready() -> void:
	initial_title = get_window().title
