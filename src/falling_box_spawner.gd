class_name FallingBoxSpawner
extends Node

signal box_spawned(box: FallingBox)

const FALLING_BOX = preload("uid://b6hwok27qogib")

@export var level: Level
@export var multiplayer_spawner: MultiplayerSpawner

@onready var spawn_timer: Timer = $Timer

var spawn_rng := RandomNumberGenerator.new()


class BoxSpawnData:
	var position: Vector2


	func with_position(value: Vector2) -> BoxSpawnData:
		position = value
		return self


func _ready() -> void:
	spawn_rng.randomize()
	spawn_timer.timeout.connect(spawn_box)
	multiplayer_spawner.spawn_function = _create_box


func _create_box(data_dict: Dictionary) -> Node:
	var spawn_data: BoxSpawnData = dict_to_inst(data_dict)
	var box: FallingBox = FALLING_BOX.instantiate()
	box.global_position = spawn_data.position
	box.reset_physics_interpolation()
	return box


func spawn_box() -> FallingBox:
	if not multiplayer.is_server():
		return null

	var spawn_data := BoxSpawnData.new().with_position(level.get_random_box_spawn_position())
	var spawned_node := multiplayer_spawner.spawn(inst_to_dict(spawn_data))
	var box := spawned_node as FallingBox
	if box:
		box_spawned.emit(box)

	return box
