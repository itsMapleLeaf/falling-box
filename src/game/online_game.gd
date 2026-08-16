class_name OnlineGame
extends Screen

@onready var game: Game = %Game
@onready var room_code_ui: RoomCodeDisplay = %RoomCodeUI
@onready var player_name_dialog: PromptDialog = %PlayerNameDialog
@onready var tube_client: TubeClient = %TubeClient


func _ready() -> void:
	game.spawn_falling_blocks()

	tube_client.error_raised.connect(
		func(code: TubeClient.SessionError, message: String) -> void:
			DebugUI.log("Network error %d: %s" % [code, message]),
	)


func _exit_tree() -> void:
	tube_client.leave_session()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


func host_room() -> void:
	get_window().title = "falling box [host]"

	tube_client.create_session()

	multiplayer.multiplayer_peer = tube_client.multiplayer_peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	await tube_client.session_created

	room_code_ui.show_room_code(tube_client.session_id)
	room_code_ui.copy_code()

	var data := await _onboard()
	game.add_player(data)


func _on_peer_connected(_peer_id: int) -> void:
	pass


func _on_peer_disconnected(peer_id: int) -> void:
	game.remove_player(peer_id)


func join_room(room_id: String) -> void:
	get_window().title = "falling box [client]"

	tube_client.join_session(room_id)

	await tube_client.session_joined

	room_code_ui.show_room_code(tube_client.session_id)

	var data := await _onboard()
	if not data:
		return

	game.enter_game.rpc_id(1, data.pack())


func _onboard() -> PlayerSpawner.PlayerSpawnData:
	var fallback_name := "Player " + str(randi() % 1000)
	player_name_dialog.placeholder = fallback_name

	var result := await player_name_dialog.ask()
	if result.cancelled:
		ScreenManager.set_screen(Screens.main_menu())
		return

	var data := PlayerSpawner.PlayerSpawnData.new()
	data.peer_id = multiplayer.get_unique_id()
	data.alias = result.answer if not result.answer.is_empty() else fallback_name
	return data
