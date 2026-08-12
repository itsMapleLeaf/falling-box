class_name Level
extends Node2D

@onready var player_spawn_left: Marker2D = %PlayerSpawnLeft
@onready var player_spawn_right: Marker2D = %PlayerSpawnRight
@onready var player_fallout: Marker2D = %PlayerFallout
@onready var box_spawn_left: Marker2D = %BoxSpawnLeft
@onready var box_spawn_right: Marker2D = %BoxSpawnRight


func get_random_player_spawn_position() -> Vector2:
	var minimum_x := minf(player_spawn_left.global_position.x, player_spawn_right.global_position.x)
	var maximum_x := maxf(player_spawn_left.global_position.x, player_spawn_right.global_position.x)
	return Vector2(randf_range(minimum_x, maximum_x), player_spawn_left.global_position.y)


func get_random_box_spawn_position() -> Vector2:
	var minimum_x := minf(box_spawn_left.global_position.x, box_spawn_right.global_position.x)
	var maximum_x := maxf(box_spawn_left.global_position.x, box_spawn_right.global_position.x)
	var minimum_cell := ceili(minimum_x / GameConfig.CELL_SIZE)
	var maximum_cell := floori(maximum_x / GameConfig.CELL_SIZE)
	var cell_x := randi_range(minimum_cell, maximum_cell)
	var spawn_y := roundf(box_spawn_left.global_position.y / GameConfig.CELL_SIZE)

	return Vector2(cell_x, spawn_y) * GameConfig.CELL_SIZE
