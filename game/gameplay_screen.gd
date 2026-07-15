extends Node2D

const LEVEL_BLOCK = preload("uid://dtvqbjemca8sx")

@export var player_spawn_height := 300

@onready var debug_menu: GameplayDebugMenu = %DebugMenu
@onready var player: CharacterBody2D = %Player

var level_blocks: Array[LevelBlock] = []
var level_bounds := Rect2(0, 0, 0, 0)


func _ready() -> void:
	_create_level_block().set_level_rect(0, 0, 20, 1)
	_create_level_block().set_level_rect(1, 1, 18, 1)
	_create_level_block().set_level_rect(2, 2, 16, 1)

	for level_block in level_blocks:
		level_bounds = level_bounds.merge(level_block.level_rect)

	_respawn_player()

	debug_menu.add_button("respawn player", _respawn_player)
	debug_menu.add_button("spawn block above player", func(): pass)


func _respawn_player() -> void:
	player.global_position = (
			level_bounds.get_center() * Constants.LEVEL_CELL_SIZE
			- Vector2(0, player_spawn_height)
	)
	player.velocity = Vector2.ZERO


func _create_level_block() -> LevelBlock:
	var block: LevelBlock = LEVEL_BLOCK.instantiate()
	add_child(block)
	level_blocks.append(block)
	return block
