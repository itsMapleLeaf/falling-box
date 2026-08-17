class_name OnlineGame
extends Screen

const GAME = preload("uid://behcxl4o21rrt")

@onready var tube_client: TubeClient = %TubeClient
@onready var connecting_status: Control = %ConnectingStatus
@onready var lobby: LobbyUI = %Lobby
@onready var player_name_dialog: PromptDialog = %PlayerNameDialog


func _ready() -> void:
	lobby.leave_requested.connect(_leave)

	tube_client.error_raised.connect(
		func(code: TubeClient.SessionError, message: String) -> void:
			DebugUI.log("Network error %d: %s" % [code, message]),
	)

	tube_client.session_left.connect(
		func() -> void:
			ScreenManager.set_screen(Screens.main_menu()),
	)


func _on_lobby_leave_requested() -> void:
	_leave()


func _leave() -> void:
	tube_client.leave_session()


func host_room() -> void:
	get_window().title = "falling box [host]"

	tube_client.create_session()

	multiplayer.multiplayer_peer = tube_client.multiplayer_peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	await tube_client.session_created

	connecting_status.hide()

	var response := await _prompt_for_alias()
	if response.cancelled:
		_leave()
		return

	lobby.show()
	lobby.set_leave_button_text("End Game")
	lobby.set_room_code(tube_client.session_id)
	lobby.add_player(multiplayer.get_unique_id(), response.answer, true)


func _on_peer_connected(peer_id: int) -> void:
	pass


func _on_peer_disconnected(peer_id: int) -> void:
	lobby.remove_player(peer_id)


func join_room(room_id: String) -> void:
	get_window().title = "falling box [client]"

	tube_client.join_session(room_id)

	await tube_client.session_joined

	connecting_status.hide()

	var response := await _prompt_for_alias()
	if response.cancelled:
		_leave()
		return

	submit_entry.rpc_id(1, response.answer)

	lobby.show()
	lobby.set_room_code(tube_client.session_id)
	lobby.set_leave_button_text("Leave")


@rpc("any_peer")
func submit_entry(alias: String) -> void:
	lobby.add_player(multiplayer.get_remote_sender_id(), alias, false)


func _prompt_for_alias() -> PromptDialog.Submission:
	var fallback_name := "Player " + str(randi() % 1000)
	player_name_dialog.placeholder = fallback_name

	var response := await player_name_dialog.ask()
	if not response.cancelled and response.answer.is_empty():
		response.answer = fallback_name

	return response
