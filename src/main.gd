extends Node

const NETWORK_MENU = preload("uid://i4jvedvwx3en")

var screen: Screen


func _set_screen(new_screen: Node) -> void:
	if screen:
		screen.queue_free()

	screen = new_screen
	screen.screen_changed.connect(_set_screen)
	add_child(screen)


func _ready() -> void:
	_set_screen(NETWORK_MENU.instantiate())
