class_name Gameplay
extends Screen

@export var falling_block_spawn_height := 1000

@onready var debug_menu: GameplayDebugMenu = %DebugMenu

var peer := ENetMultiplayerPeer.new()

var players_by_peer_id: Dictionary[int, Player] = { }


func _ready() -> void:
	var level_blocks := Globals.default_level.create_level_blocks()
	for block in level_blocks:
		add_child(block, true)

	var args := OS.get_cmdline_user_args()
	prints("Launch args: ", args)

	match Array(args):
		["host", var port]:
			_host_server(int(port))

		["join", var host, var port]:
			_join_server(host, int(port))

		_:
			push_error("invalid arguments:", args)
			get_tree().quit(1)


func _host_server(port: int) -> void:
	peer.peer_connected.connect(_on_peer_connected)
	peer.peer_disconnected.connect(_on_peer_disconnected)
	peer.create_server(port)

	multiplayer.multiplayer_peer = peer

	add_player(1)


func _join_server(address: String, port: int) -> void:
	peer.create_client(address, port)
	multiplayer.multiplayer_peer = peer


func _on_peer_connected(peer_id: int) -> void:
	add_player(peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	remove_player(peer_id)


func exit_screen() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


func add_player(peer_id: int) -> Player:
	var player: Player = load("uid://48dg7eo7ue11").instantiate()

	player.name = str(peer_id)
	player.block_yeeted.connect(_on_player_block_yeeted)

	players_by_peer_id[peer_id] = player

	add_child(player)

	return player


func remove_player(peer_id) -> void:
	var player := players_by_peer_id[peer_id]
	if player:
		players_by_peer_id.erase(peer_id)
		player.queue_free()


func _on_block_spawn_timer_timeout() -> void:
	if multiplayer.is_server():
		var block: Node2D = load("uid://bc6jrwvfpr8s5").instantiate()
		block.global_position = (
			Vector2(
				randi_range(
					Globals.default_level.bounds.position.x,
					Globals.default_level.bounds.end.x - 1,
				)
				* Level.CELL_SIZE,
				-falling_block_spawn_height,
			)
		)
		print(block.global_position.x)
		add_child(block, true)


func _on_player_block_yeeted(_player: Player, at: Vector2, direction: int) -> void:
	var block: FlyingBlock = load("uid://x6duholk1sc1").instantiate()
	block.global_position = at
	block.direction = direction
	add_child(block, true)

#func _debug_spawn_block_above_player():
#const FALLING_BLOCK = preload("uid://bc6jrwvfpr8s5")
#var block: Node2D = FALLING_BLOCK.instantiate()
#block.global_position = player.global_position - Vector2(0, 500)
#add_child(block)
