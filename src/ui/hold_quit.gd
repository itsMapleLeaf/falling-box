extends CanvasLayer

@onready var hold_quit_timer: Timer = %Timer


func _ready() -> void:
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		hold_quit_timer.start()
		show()

	if event.is_action_released("pause"):
		hold_quit_timer.stop()
		hide()


func _on_hold_quit_timer_timeout() -> void:
	ScreenManager.set_screen(Screens.main_menu())
