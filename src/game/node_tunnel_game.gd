class_name NodeTunnelGame
extends Screen

const NODETUNNEL_RELAY = "us-east.nodetunnel.io:8080"
const NODETUNNEL_TOKEN = "770yu76a0drqcx7"

var nodetunnel := NodeTunnelPeer.new()

@onready var game: Game = %Game
@onready var room_code_ui: RoomCodeDisplay = %RoomCodeUI
@onready var player_name_dialog: PromptDialog = %PlayerNameDialog


func _ready() -> void:
	game.spawn_falling_blocks()

	nodetunnel.error.connect(
		func(msg):
			DebugUI.log("Relay sent error: " + msg),
	)

	nodetunnel.forced_disconnect.connect(
		func():
			DebugUI.log("Disconnected from relay")
			ScreenManager.set_screen(Screens.main_menu()),
	)

	nodetunnel.room_connected.connect(
		func():
			prints("Connected to room:", nodetunnel.room_id)
			DebugUI.log("Connected to room"),
	)


func _exit_tree() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


func host_room() -> void:
	get_window().title = "falling box [nodetunnel host]"

	nodetunnel.connect_to_relay(NODETUNNEL_RELAY, NODETUNNEL_TOKEN)

	multiplayer.multiplayer_peer = nodetunnel
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	await nodetunnel.authenticated

	nodetunnel.host_room(false, "")

	await nodetunnel.room_connected

	room_code_ui.show_room_code(nodetunnel.room_id)
	room_code_ui.copy_code()

	var data := await _onboard()
	game.add_player(data)


func _on_peer_connected(_peer_id: int) -> void:
	# game.add_player(PlayerSpawner.PlayerSpawnData.new(peer_id))
	pass


func _on_peer_disconnected(peer_id: int) -> void:
	game.remove_player(peer_id)


func join_room(room_id: String) -> void:
	get_window().title = "falling box [nodetunnel client]"

	nodetunnel.connect_to_relay(NODETUNNEL_RELAY, NODETUNNEL_TOKEN)
	multiplayer.multiplayer_peer = nodetunnel

	await nodetunnel.authenticated

	nodetunnel.join_room(room_id)

	await nodetunnel.room_connected

	room_code_ui.show_room_code(nodetunnel.room_id)

	var data := await _onboard()
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
