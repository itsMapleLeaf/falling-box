class_name Gameplay
extends Screen

const MULTIPLAYER_PORT = 7586 # "TFBG" (an attempt at that)
var multiplayer_peer := ENetMultiplayerPeer.new()

@export var player_spawn_height := 500
@export var falling_block_spawn_height := 1000

var level_blocks: Array[LevelBlock] = []
var level_bounds := Rect2i(0, 0, 0, 0)

@onready var debug_menu: GameplayDebugMenu = %DebugMenu
@onready var falling_blocks: Node2D = %FallingBlocks
@onready var flying_blocks: Node2D = %FlyingBlocks
@onready var players: Node2D = %Players
@onready var camera: Camera = %Camera

var players_by_peer_id: Dictionary[int, Player] = { }


func _ready() -> void:
	_create_level_block().set_level_rect(0, 0, 24, 1)
	_create_level_block().set_level_rect(1, 1, 22, 1)
	_create_level_block().set_level_rect(2, 2, 20, 1)

	for level_block in level_blocks:
		level_bounds = level_bounds.merge(level_block.level_rect)

	#debug_menu.add_button("respawn player", _respawn_player)
	#debug_menu.add_button("spawn block above player", _debug_spawn_block_above_player)


func start_server() -> void:
	multiplayer_peer.create_server(MULTIPLAYER_PORT)
	multiplayer_peer.peer_connected.connect(_on_peer_connected)
	multiplayer_peer.peer_disconnected.connect(_on_peer_disconnected)

	multiplayer.multiplayer_peer = multiplayer_peer

	_create_player(multiplayer_peer.get_unique_id())


func start_client() -> void:
	multiplayer_peer.create_client("localhost", MULTIPLAYER_PORT)
	multiplayer.multiplayer_peer = multiplayer_peer


func exit_screen() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


func _on_peer_connected(peer_id: int) -> void:
	_create_player(peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	_remove_player(peer_id)


func _create_player(peer_id: int) -> void:
	var player: Player = load("uid://48dg7eo7ue11").instantiate()
	players.add_child(player, true)

	if not camera.target:
		camera.target = player

	players_by_peer_id[peer_id] = player

	player.global_position = (
		Vector2(level_bounds.get_center()) * Constants.LEVEL_CELL_SIZE - Vector2(
				0,
				player_spawn_height,
		)
	)
	player.velocity = Vector2.ZERO
	player.block_yeeted.connect(_on_player_block_yeeted)


func _remove_player(peer_id: int) -> void:
	var player := players_by_peer_id[peer_id]
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
		falling_blocks.add_child(block, true)


func _on_player_block_yeeted(_player: Player, at: Vector2, direction: int) -> void:
	var block: FlyingBlock = load("uid://x6duholk1sc1").instantiate()
	block.global_position = at
	block.direction = direction
	flying_blocks.add_child(block, true)

#func _debug_spawn_block_above_player():
#const FALLING_BLOCK = preload("uid://bc6jrwvfpr8s5")
#var block: Node2D = FALLING_BLOCK.instantiate()
#block.global_position = player.global_position - Vector2(0, 500)
#add_child(block)
