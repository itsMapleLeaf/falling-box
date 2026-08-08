@abstract
class_name Screen extends Node

signal screen_changed(new_screen: Screen)


func _change_screen(new_screen: Screen) -> void:
	screen_changed.emit(new_screen)
