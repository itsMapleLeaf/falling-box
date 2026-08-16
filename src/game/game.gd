class_name Game
extends Screen

var players_by_peer_id: Dictionary[int, Player] = { }

@onready var level: Level = %Level
@onready var player_spawner: PlayerSpawner = %PlayerSpawner
@onready var falling_box_spawner: MultiplayerSpawner = %FallingBoxSpawner
@onready var falling_box_spawn_timer: Timer = %FallingBoxSpawnTimer
@onready var flying_box_spawner: FlyingBoxSpawner = %FlyingBoxSpawner


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _on_peer_connected(peer_id: int) -> void:
	prints("Player connected:", peer_id)
	DebugUI.log("New player connected")


func _on_peer_disconnected(peer_id: int) -> void:
	prints("Player disconnected:", peer_id)


func _on_connected_to_server() -> void:
	DebugUI.log("Connected to server")


func _on_server_disconnected() -> void:
	ScreenManager.set_screen(Screens.main_menu())
	DebugUI.log("Disconnected from server")


func add_player(data: PlayerSpawner.PlayerSpawnData) -> Player:
	var player: Player = player_spawner.spawn(inst_to_dict(data))
	players_by_peer_id[data.peer_id] = player
	return player


func remove_player(peer_id: int) -> void:
	var player: Player = players_by_peer_id.get(peer_id)
	if player:
		player.queue_free()
		players_by_peer_id.erase(peer_id)


func spawn_falling_blocks() -> void:
	falling_box_spawn_timer.start()
	falling_box_spawn_timer.timeout.connect(spawn_falling_block)


func spawn_falling_block() -> void:
	var box_spawn_data := FallingBoxSpawner.BoxSpawnData.new().with_position(
		level.get_random_box_spawn_position()
	)
	falling_box_spawner.spawn(inst_to_dict(box_spawn_data))


@rpc("any_peer")
func enter_game(player_data_packed: Dictionary) -> void:
	add_player(PlayerSpawner.PlayerSpawnData.unpack(player_data_packed))
