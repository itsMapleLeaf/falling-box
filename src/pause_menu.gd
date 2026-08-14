extends CanvasLayer

@onready var resume_button: Button = %ResumeButton


func _on_visibility_changed() -> void:
	if visible:
		resume_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	get_viewport().set_input_as_handled()
	if event.is_action_pressed("pause"):
		_resume()


func _on_resume_button_pressed() -> void:
	_resume()


func _resume() -> void:
	hide()
	get_tree().set_deferred('paused', false)


func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	const NETWORK_MENU = preload("uid://i4jvedvwx3en")
	ScreenManager.set_screen(NETWORK_MENU.instantiate())
