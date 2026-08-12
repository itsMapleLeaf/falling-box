class_name Game
extends Screen

const PLAYER = preload("uid://dgfxlv2n2qtvd")

var enet_peer := ENetMultiplayerPeer.new()
var players_by_peer_id: Dictionary[int, Player] = { }

@onready var player_multiplayer_spawner: MultiplayerSpawner = $PlayerMultiplayerSpawner
@onready var level: Level = %Level


func _ready() -> void:
	player_multiplayer_spawner.spawn_function = _spawn_player


func play_offline() -> void:
	var player: Player = PLAYER.instantiate()
	player.level = level
	player.is_local = true
	add_child(player)


class PlayerSpawnData:
	var peer_id: int


	func with_peer_id(value: int) -> PlayerSpawnData:
		peer_id = value
		return self


func _spawn_player(data_dict: Dictionary):
	var player: Player = PLAYER.instantiate()
	var data: PlayerSpawnData = dict_to_inst(data_dict)

	player.name = str(data.peer_id)
	player.level = level

	players_by_peer_id[data.peer_id] = player

	return player


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_quit"):
		_change_screen(load("uid://i4jvedvwx3en").instantiate())


func host_server(port: int) -> void:
	enet_peer.create_server(port)
	multiplayer.multiplayer_peer = enet_peer

	enet_peer.peer_connected.connect(_on_peer_connected)
	enet_peer.peer_disconnected.connect(_on_peer_disconnected)

	player_multiplayer_spawner.spawn(inst_to_dict(PlayerSpawnData.new().with_peer_id(1)))


func join_server(host: String, port: int) -> void:
	enet_peer.create_client(host, port)
	multiplayer.multiplayer_peer = enet_peer


func _on_peer_connected(peer_id: int) -> void:
	prints("connected:", peer_id)

	player_multiplayer_spawner.spawn(inst_to_dict(PlayerSpawnData.new().with_peer_id(peer_id)))


func _on_peer_disconnected(peer_id: int) -> void:
	prints("disconnected:", peer_id)
	remove_player(peer_id)


func remove_player(peer_id: int) -> void:
	var player := players_by_peer_id[peer_id]
	if player:
		player.queue_free()
		players_by_peer_id.erase(peer_id)
