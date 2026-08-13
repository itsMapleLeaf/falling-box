class_name Game
extends Screen

@onready var level: Level = %Level
@onready var falling_box_spawn_timer: Timer = %FallingBoxSpawnTimer

var enet_peer := ENetMultiplayerPeer.new()
var players_by_peer_id: Dictionary[int, Player] = { }

@onready var player_spawner: MultiplayerSpawner = %PlayerMultiplayerSpawner
@onready var falling_box_spawner: MultiplayerSpawner = %FallingBoxMultiplayerSpawner
@onready var flying_box_spawner: FlyingBoxSpawner = %FlyingBoxSpawner


func _ready() -> void:
	player_spawner.spawn_function = _create_spawned_player
	falling_box_spawner.spawn_function = _create_spawned_box


func _exit_tree() -> void:
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

	_init_offline_server_shared()


func join_server(host: String, port: int) -> void:
	get_window().title = "falling box [client]"

	enet_peer.create_client(host, port)
	multiplayer.multiplayer_peer = enet_peer

	enet_peer.peer_connected.connect(_on_peer_connected)
	enet_peer.peer_disconnected.connect(_on_peer_disconnected)

	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func play_offline() -> void:
	get_window().title = "falling box [offline]"

	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

	_init_offline_server_shared()


func _init_offline_server_shared() -> void:
	player_spawner.spawn(inst_to_dict(PlayerSpawnData.new().with_peer_id(1)))

	falling_box_spawn_timer.timeout.connect(_on_falling_box_spawn_timer_timeout)

	_identify()


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
		player.set_name_tag_text("Player " + str(randi() % 1000))


class PlayerSpawnData:
	var peer_id: int


	func with_peer_id(value: int) -> PlayerSpawnData:
		peer_id = value
		return self


func _create_spawned_player(data_dict: Dictionary):
	var data: PlayerSpawnData = dict_to_inst(data_dict)

	const PLAYER = preload("uid://dgfxlv2n2qtvd")
	var player: Player = PLAYER.instantiate()
	player.level = level
	player.set_multiplayer_authority(data.peer_id)
	player.released.connect(_on_player_released)
	players_by_peer_id[data.peer_id] = player

	return player


# there's probably a better way to do this
func _on_player_released(player_id: int, at_position: Vector2, facing: Facing.Facing) -> void:
	create_flying_block.rpc(player_id, at_position, facing)


@rpc("any_peer", "call_local")
func create_flying_block(player_id: int, at_position: Vector2, facing: Facing.Facing) -> void:
	if multiplayer.is_server():
		var data := FlyingBoxSpawner.FlyingBoxData.new()
		data.owner_player_id = player_id
		data.position = at_position
		data.facing = facing
		flying_box_spawner.spawn_flying_box(data)


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
	const FALLING_BOX = preload("uid://b6hwok27qogib")
	var box: FallingBox = FALLING_BOX.instantiate()
	box.global_position = spawn_data.position
	box.reset_physics_interpolation()
	return box


func _on_falling_box_spawn_timer_timeout() -> void:
	var box_spawn_data: BoxSpawnData = BoxSpawnData.new().with_position(
		level.get_random_box_spawn_position()
	)
	falling_box_spawner.spawn(inst_to_dict(box_spawn_data))
