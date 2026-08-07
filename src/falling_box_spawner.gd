class_name FallingBoxSpawner
extends Node

signal box_spawned(box: FallingBox)

@export var box_scene: PackedScene
@export var box_parent: Node2D
@export var spawn_left: Marker2D
@export var spawn_right: Marker2D
@export var spawn_timer: Timer

var spawn_rng := RandomNumberGenerator.new()


func _ready() -> void:
	spawn_rng.randomize()
	spawn_timer.timeout.connect(spawn_box)


func spawn_box() -> FallingBox:
	var box := box_scene.instantiate() as FallingBox
	box_parent.add_child(box)
	box.global_position = _random_spawn_position()
	box.reset_physics_interpolation()
	box_spawned.emit(box)
	return box


func _random_spawn_position() -> Vector2:
	var minimum_x := minf(spawn_left.global_position.x, spawn_right.global_position.x)
	var maximum_x := maxf(spawn_left.global_position.x, spawn_right.global_position.x)
	var minimum_cell := ceili(minimum_x / GameConfig.CELL_SIZE)
	var maximum_cell := floori(maximum_x / GameConfig.CELL_SIZE)
	var cell_x := spawn_rng.randi_range(minimum_cell, maximum_cell)
	var spawn_y := roundf(spawn_left.global_position.y / GameConfig.CELL_SIZE)

	return Vector2(cell_x, spawn_y) * GameConfig.CELL_SIZE
