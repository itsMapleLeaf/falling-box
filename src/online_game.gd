class_name OnlineGame
extends Screen

const PLAYER = preload("uid://dgfxlv2n2qtvd")
const FALLING_BOX = preload("uid://b6hwok27qogib")

var enet_peer := ENetMultiplayerPeer.new()
var players_by_peer_id: Dictionary[int, Player] = { }

@onready var game: Game = %Game
@onready var player_spawner: MultiplayerSpawner = %PlayerMultiplayerSpawner
@onready var falling_box_spawner: MultiplayerSpawner = %FallingBoxMultiplayerSpawner


func _ready() -> void:
	player_spawner.spawn_function = _create_spawned_player
	falling_box_spawner.spawn_function = _create_spawned_box


func exit_screen() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_quit"):
		var main_menu: MainMenu = load("uid://i4jvedvwx3en").instantiate()
		_change_screen(main_menu)


func host_server(port: int) -> void:
	get_window().title = "falling box [server]"

	enet_peer.create_server(port)
	multiplayer.multiplayer_peer = enet_peer

	enet_peer.peer_connected.connect(_on_peer_connected)
	enet_peer.peer_disconnected.connect(_on_peer_disconnected)

	player_spawner.spawn(inst_to_dict(PlayerSpawnData.new().with_peer_id(1)))

	game.falling_box_spawn_timer.timeout.connect(_on_falling_box_spawn_timer_timeout)

	_identify()


func join_server(host: String, port: int) -> void:
	get_window().title = "falling box [client]"

	enet_peer.create_client(host, port)
	multiplayer.multiplayer_peer = enet_peer

	enet_peer.peer_connected.connect(_on_peer_connected)
	enet_peer.peer_disconnected.connect(_on_peer_disconnected)

	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _on_peer_connected(peer_id: int) -> void:
	prints("connected:", peer_id)

	if multiplayer.is_server():
		player_spawner.spawn(inst_to_dict(PlayerSpawnData.new().with_peer_id(peer_id)))
		_identify.rpc_id(peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	prints("disconnected:", peer_id)
	remove_player(peer_id)


func _on_connected_to_server() -> void:
	pass


func _on_server_disconnected() -> void:
	_change_screen(load("res://src/main_menu.tscn").instantiate())
	DebugUI.log("Disconnected from server")


@rpc
func _identify() -> void:
	DebugUI.log("Joined game")

	var peer_id := multiplayer.get_unique_id()
	var player := players_by_peer_id[peer_id]
	if player:
		player.set_name_tag_text("Sample Text " + str(randi() % 1000))


class PlayerSpawnData:
	var peer_id: int


	func with_peer_id(value: int) -> PlayerSpawnData:
		peer_id = value
		return self


func _create_spawned_player(data_dict: Dictionary):
	var player := game.create_player()
	var data: PlayerSpawnData = dict_to_inst(data_dict)
	player.name = str(data.peer_id)
	players_by_peer_id[data.peer_id] = player
	return player


func remove_player(peer_id: int) -> void:
	var player := players_by_peer_id[peer_id]
	if player:
		player.queue_free()
		players_by_peer_id.erase(peer_id)


class BoxSpawnData:
	var position: Vector2


	func with_position(value: Vector2) -> BoxSpawnData:
		position = value
		return self


func _create_spawned_box(data_dict: Dictionary) -> Node:
	var spawn_data: BoxSpawnData = dict_to_inst(data_dict)
	var box: FallingBox = FALLING_BOX.instantiate()
	box.global_position = spawn_data.position
	box.reset_physics_interpolation()
	return box


func _on_falling_box_spawn_timer_timeout() -> void:
	var box_spawn_data: BoxSpawnData = BoxSpawnData.new().with_position(
		game.level.get_random_box_spawn_position()
	)
	falling_box_spawner.spawn(inst_to_dict(box_spawn_data))
