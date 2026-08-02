class_name GameplayDebugMenu
extends Control

@onready var button_list: HFlowContainer = %ButtonList


func add_button(text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(callback)

	button_list.add_child(button)
