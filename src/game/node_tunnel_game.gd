class_name NodeTunnelGame
extends Screen

const NODETUNNEL_RELAY = "us-east.nodetunnel.io:8080"
const NODETUNNEL_TOKEN = "770yu76a0drqcx7"

var nodetunnel := NodeTunnelPeer.new()

@onready var game: Game = %Game
@onready var room_code_ui: RoomCodeDisplay = %RoomCodeUI


func _ready() -> void:
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
			DebugUI.log("Connected to room: %s" % nodetunnel.room_id),
	)


func _exit_tree() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


func host_room() -> void:
	get_window().title = "falling box [nodetunnel host]"

	nodetunnel.connect_to_relay(NODETUNNEL_RELAY, NODETUNNEL_TOKEN)
	multiplayer.multiplayer_peer = nodetunnel

	await nodetunnel.authenticated

	nodetunnel.host_room(false, "")

	await nodetunnel.room_connected

	room_code_ui.show_room_code(nodetunnel.room_id)

	game.player_spawner.spawn(inst_to_dict(PlayerSpawner.PlayerSpawnData.new().with_peer_id(1)))

	nodetunnel.peer_connected.connect(game._on_peer_connected)
	nodetunnel.peer_disconnected.connect(game._on_peer_disconnected)
	game.falling_box_spawn_timer.timeout.connect(game._on_falling_box_spawn_timer_timeout)


func join_room(room_id: String) -> void:
	get_window().title = "falling box [nodetunnel client]"

	nodetunnel.connect_to_relay(NODETUNNEL_RELAY, NODETUNNEL_TOKEN)
	multiplayer.multiplayer_peer = nodetunnel

	await nodetunnel.authenticated

	nodetunnel.join_room(room_id)

	await nodetunnel.room_connected

	room_code_ui.show_room_code(nodetunnel.room_id)

	nodetunnel.peer_connected.connect(game._on_peer_connected)
	nodetunnel.peer_disconnected.connect(game._on_peer_disconnected)

	multiplayer.connected_to_server.connect(game._on_connected_to_server)
	multiplayer.server_disconnected.connect(game._on_server_disconnected)
