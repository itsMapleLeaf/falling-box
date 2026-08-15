class_name ServerGame
extends Screen

var enet_peer := ENetMultiplayerPeer.new()

@onready var game: Game = %Game
@onready var overview_camera: OverviewCamera = %OverviewCamera


func _exit_tree() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


func host_server(port: int) -> void:
	get_window().title = "falling box [server]"

	enet_peer.create_server(port)
	multiplayer.multiplayer_peer = enet_peer

	enet_peer.peer_connected.connect(_on_peer_connected)
	enet_peer.peer_disconnected.connect(_on_peer_disconnected)

	game.falling_box_spawn_timer.timeout.connect(game._on_falling_box_spawn_timer_timeout)

	overview_camera.enabled = true


func _on_peer_connected(peer_id) -> void:
	game._on_peer_connected(peer_id)

	var player: Player = game.players_by_peer_id.get(peer_id)
	if player:
		overview_camera.targets.append(player)


func _on_peer_disconnected(peer_id) -> void:
	var player: Player = game.players_by_peer_id.get(peer_id)
	if player:
		overview_camera.targets.erase(player)

	game._on_peer_disconnected(peer_id)


func join_server(host: String, port: int) -> void:
	get_window().title = "falling box [client]"

	enet_peer.create_client(host, port)
	multiplayer.multiplayer_peer = enet_peer

	enet_peer.peer_connected.connect(game._on_peer_connected)
	enet_peer.peer_disconnected.connect(game._on_peer_disconnected)

	multiplayer.connected_to_server.connect(game._on_connected_to_server)
	multiplayer.server_disconnected.connect(game._on_server_disconnected)
