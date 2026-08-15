extends CanvasLayer

@export var game: Game

@onready var resume_button: Button = %ResumeButton


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("pause"):
		_resume.call_deferred()
		get_viewport().set_input_as_handled()

	if not visible and event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		show()
		game.process_mode = PROCESS_MODE_DISABLED


func _on_resume_button_pressed() -> void:
	_resume()


func _resume() -> void:
	hide()
	game.set_deferred('process_mode', PROCESS_MODE_INHERIT)


func _on_visibility_changed() -> void:
	if visible:
		resume_button.grab_focus()


func _on_quit_button_pressed() -> void:
	const NETWORK_MENU = preload("uid://i4jvedvwx3en")
	ScreenManager.set_screen(NETWORK_MENU.instantiate())
