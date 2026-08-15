class_name NodeTunnelGame
extends Screen

const NODETUNNEL_RELAY = "us-east.nodetunnel.io:8080"
const NODETUNNEL_TOKEN = "770yu76a0drqcx7"

var nodetunnel := NodeTunnelPeer.new()

@onready var game: Game = %Game


func _ready() -> void:
	nodetunnel.error.connect(
		func(msg):
			DebugUI.log("Relay sent error: " + msg),
	)

	nodetunnel.forced_disconnect.connect(
		func():
			DebugUI.log("Disconnected from relay")
			var main_menu: Screen = load("uid://i4jvedvwx3en").instantiate()
			ScreenManager.set_screen(main_menu),
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

	nodetunnel.authenticated.connect(
		func():
			nodetunnel.host_room(false, ""),
	)

	nodetunnel.room_connected.connect(
		func():
			game.player_spawner.spawn(
				inst_to_dict(PlayerSpawner.PlayerSpawnData.new().with_peer_id(1))
			),
	)

	multiplayer.multiplayer_peer = nodetunnel

	nodetunnel.peer_connected.connect(game._on_peer_connected)
	nodetunnel.peer_disconnected.connect(game._on_peer_disconnected)
	game.falling_box_spawn_timer.timeout.connect(game._on_falling_box_spawn_timer_timeout)


func join_room(room_id: String) -> void:
	get_window().title = "falling box [nodetunnel client]"

	nodetunnel.connect_to_relay(NODETUNNEL_RELAY, NODETUNNEL_TOKEN)

	nodetunnel.authenticated.connect(
		func():
			nodetunnel.join_room(room_id),
	)

	multiplayer.multiplayer_peer = nodetunnel

	nodetunnel.peer_connected.connect(game._on_peer_connected)
	nodetunnel.peer_disconnected.connect(game._on_peer_disconnected)

	multiplayer.connected_to_server.connect(game._on_connected_to_server)
	multiplayer.server_disconnected.connect(game._on_server_disconnected)
