extends Node

@onready var hold_quit_message: CanvasLayer = %HoldQuitMessage
@onready var hold_quit_timer: Timer = %HoldQuitTimer


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		hold_quit_timer.start()
		hold_quit_message.show()

	if event.is_action_released("pause"):
		hold_quit_timer.stop()
		hold_quit_message.hide()


func _on_hold_quit_timer_timeout() -> void:
	ScreenManager.set_screen(Screens.main_menu())
