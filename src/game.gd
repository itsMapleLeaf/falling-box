class_name Game
extends Node2D

const FALLING_BOX = preload("uid://b6hwok27qogib")

@onready var level: Level = %Level
@onready var falling_box_spawn_timer: Timer = %FallingBoxSpawnTimer


func create_player() -> Player:
	const PLAYER = preload("uid://dgfxlv2n2qtvd")
	var player: Player = PLAYER.instantiate()
	player.level = level
	return player


func create_falling_box(box_position: Vector2) -> FallingBox:
	var box: FallingBox = FALLING_BOX.instantiate()
	box.global_position = box_position
	box.reset_physics_interpolation()
	return box
