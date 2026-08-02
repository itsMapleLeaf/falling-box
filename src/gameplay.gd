class_name Gameplay
extends Screen

@export var player_spawn_height := 500
@export var falling_block_spawn_height := 1000

var level_blocks: Array[LevelBlock] = []
var level_bounds := Rect2i(0, 0, 0, 0)

@onready var debug_menu: GameplayDebugMenu = %DebugMenu

var peer := ENetMultiplayerPeer.new()

var players_by_peer_id: Dictionary[int, Player] = { }


func _ready() -> void:
	_create_level_block().set_level_rect(0, 0, 24, 1)
	_create_level_block().set_level_rect(1, 1, 22, 1)
	_create_level_block().set_level_rect(2, 2, 20, 1)

	for level_block in level_blocks:
		level_bounds = level_bounds.merge(level_block.level_rect)

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
	
	# there's a dumb timing issue that i dunno how to resolve
	await get_tree().create_timer(1).timeout

	player.spawn_at.rpc(
			Vector2(level_bounds.get_center()) * Constants.LEVEL_CELL_SIZE - Vector2(
					0,
					player_spawn_height,
			)
	)

	return player


func remove_player(peer_id) -> void:
	var player := players_by_peer_id[peer_id]
	if player:
		players_by_peer_id.erase(peer_id)
		player.queue_free()


func _create_level_block() -> LevelBlock:
	var block: LevelBlock = load("uid://dtvqbjemca8sx").instantiate()
	add_child(block, true)
	level_blocks.append(block)
	return block


func _on_block_spawn_timer_timeout() -> void:
	if multiplayer.is_server():
		var block: Node2D = load("uid://bc6jrwvfpr8s5").instantiate()
		block.global_position = Vector2(
				randi_range(level_bounds.position.x, level_bounds.end.x - 1) * Constants.LEVEL_CELL_SIZE,
				-falling_block_spawn_height,
		)
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
