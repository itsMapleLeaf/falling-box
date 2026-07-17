extends Node2D

const LEVEL_BLOCK = preload("uid://dtvqbjemca8sx")
const FALLING_BLOCK = preload("uid://bc6jrwvfpr8s5")

@export var player_spawn_height := 500
@export var falling_block_spawn_height := 1000

var level_blocks: Array[LevelBlock] = []
var level_bounds := Rect2i(0, 0, 0, 0)

@onready var debug_menu: GameplayDebugMenu = %DebugMenu
@onready var player: CharacterBody2D = %Player
@onready var falling_blocks: Node2D = %FallingBlocks


func _ready() -> void:
	_create_level_block().set_level_rect(0, 0, 24, 1)
	_create_level_block().set_level_rect(1, 1, 22, 1)
	_create_level_block().set_level_rect(2, 2, 20, 1)

	for level_block in level_blocks:
		level_bounds = level_bounds.merge(level_block.level_rect)

	_respawn_player()

	debug_menu.add_button("respawn player", _respawn_player)
	debug_menu.add_button("spawn block above player", _debug_spawn_block_above_player)


func _respawn_player() -> void:
	player.global_position = (
		Vector2(level_bounds.get_center()) * Constants.LEVEL_CELL_SIZE - Vector2(
				0,
				player_spawn_height,
		)
	)
	player.velocity = Vector2.ZERO


func _create_level_block() -> LevelBlock:
	var block: LevelBlock = LEVEL_BLOCK.instantiate()
	add_child(block)
	level_blocks.append(block)
	return block


func _on_block_spawn_timer_timeout() -> void:
	var block: Node2D = FALLING_BLOCK.instantiate()
	block.global_position = Vector2(
			randi_range(level_bounds.position.x, level_bounds.end.x - 1) * Constants.LEVEL_CELL_SIZE,
			-falling_block_spawn_height,
	)
	falling_blocks.add_child(block)


func _debug_spawn_block_above_player():
	var block: Node2D = FALLING_BLOCK.instantiate()
	block.global_position = player.global_position - Vector2(0, 500)
	add_child(block)
