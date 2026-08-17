class_name MainMenu
extends Screen

@onready var play_button: Button = %PlayButton
@onready var host_room_button: Button = %HostRoomButton
@onready var join_room_button: Button = %JoinRoomButton
@onready var join_room_prompt: PromptDialog = %JoinRoomPrompt
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	play_button.grab_focus()

	if OS.has_feature("web"):
		quit_button.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_quit"):
		get_tree().quit()


func _on_play_button_pressed() -> void:
	ScreenManager.set_screen(Screens.local_game())


func _on_host_room_button_pressed() -> void:
	var game: OnlineGame = Screens.node_tunnel_game()
	ScreenManager.set_screen(game)
	game.host_room()


func _on_join_room_button_pressed() -> void:
	var result: PromptDialog.Submission = await join_room_prompt.ask()
	if result.cancelled:
		return

	var game: OnlineGame = Screens.node_tunnel_game()
	ScreenManager.set_screen(game)
	game.join_room(result.answer)


func _on_quit_button_pressed() -> void:
	if not OS.has_feature("web"):
		get_tree().quit()
