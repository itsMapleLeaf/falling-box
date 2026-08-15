class_name Game
extends Screen

var players_by_peer_id: Dictionary[int, Player] = { }

@onready var level: Level = %Level
@onready var falling_box_spawn_timer: Timer = %FallingBoxSpawnTimer
@onready var player_spawner: MultiplayerSpawner = %PlayerMultiplayerSpawner
@onready var falling_box_spawner: MultiplayerSpawner = %FallingBoxMultiplayerSpawner
@onready var flying_box_spawner: FlyingBoxSpawner = %FlyingBoxSpawner


func _ready() -> void:
	player_spawner.spawn_function = _create_spawned_player
	falling_box_spawner.spawn_function = _create_spawned_box


func _on_peer_connected(peer_id: int) -> void:
	if multiplayer.is_server():
		player_spawner.spawn(inst_to_dict(PlayerSpawnData.new().with_peer_id(peer_id)))

		var alias := "Player " + str(randi() % 1000)
		_identify.rpc_id(peer_id, alias)

		DebugUI.log("%s has joined the game" % alias)


func _on_peer_disconnected(peer_id: int) -> void:
	var player: Player = players_by_peer_id.get(peer_id)

	DebugUI.log("%s has left the game" % player.alias)
	remove_player(peer_id)


func _on_connected_to_server() -> void:
	DebugUI.log("Connected to server")


func _on_server_disconnected() -> void:
	_change_screen(load("res://src/main_menu.tscn").instantiate())
	DebugUI.log("Disconnected from server")


@rpc
func _identify(alias: String) -> void:
	var peer_id := multiplayer.get_unique_id()
	var player := players_by_peer_id[peer_id]
	if player:
		player.set_name_tag_text(alias)


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
	var player := players_by_peer_id[peer_id] if peer_id in players_by_peer_id else null
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
