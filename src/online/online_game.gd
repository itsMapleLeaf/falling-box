class_name OnlineGame
extends Screen

const GAME = preload("uid://behcxl4o21rrt")

@onready var tube_client: TubeClient = %TubeClient
@onready var connecting_status: Control = %ConnectingStatus
@onready var lobby: LobbyUI = %Lobby
@onready var player_name_dialog: PromptDialog = %PlayerNameDialog


func _ready() -> void:
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

	#connecting_status.hide()
	var data := await _onboard()
	if not data:
		return

	lobby.show()


func _on_peer_connected(_peer_id: int) -> void:
	pass


func _on_peer_disconnected(peer_id: int) -> void:
	#game.remove_player(peer_id)
	pass


func join_room(room_id: String) -> void:
	get_window().title = "falling box [client]"

	tube_client.join_session(room_id)

	await tube_client.session_joined

	connecting_status.hide()

	var data := await _onboard()
	if not data:
		return

	lobby.show()


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
