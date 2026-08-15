class_name Game
extends Screen

var players_by_peer_id: Dictionary[int, Player] = { }

@onready var level: Level = %Level
@onready var falling_box_spawn_timer: Timer = %FallingBoxSpawnTimer
@onready var player_spawner: MultiplayerSpawner = %PlayerSpawner
@onready var falling_box_spawner: MultiplayerSpawner = %FallingBoxSpawner
@onready var flying_box_spawner: FlyingBoxSpawner = %FlyingBoxSpawner


func _on_peer_connected(peer_id: int) -> void:
	if multiplayer.is_server():
		var player: Player = player_spawner.spawn(
			inst_to_dict(PlayerSpawner.PlayerSpawnData.new().with_peer_id(peer_id))
		)
		DebugUI.log("%s has joined the game" % player.alias)


func _on_peer_disconnected(peer_id: int) -> void:
	var player: Player = players_by_peer_id.get(peer_id)
	DebugUI.log("%s has left the game" % player.alias)
	remove_player(peer_id)


func _on_connected_to_server() -> void:
	DebugUI.log("Connected to server")


func _on_server_disconnected() -> void:
	_change_screen(load("res://src/main_menu.tscn").instantiate())
	DebugUI.log("Disconnected from server")


func remove_player(peer_id: int) -> void:
	var player := players_by_peer_id[peer_id] if peer_id in players_by_peer_id else null
	if player:
		player.queue_free()
		players_by_peer_id.erase(peer_id)


func _on_falling_box_spawn_timer_timeout() -> void:
	var box_spawn_data := FallingBoxSpawner.BoxSpawnData.new().with_position(
		level.get_random_box_spawn_position()
	)
	falling_box_spawner.spawn(inst_to_dict(box_spawn_data))
