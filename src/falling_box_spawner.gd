class_name FallingBoxSpawner
extends MultiplayerSpawner

@export var level: Level


class BoxSpawnData:
	var position: Vector2


	func with_position(value: Vector2) -> BoxSpawnData:
		position = value
		return self


func _ready() -> void:
	spawn_function = _create_spawned_box


func _create_spawned_box(data_dict: Dictionary) -> Node:
	var spawn_data: BoxSpawnData = dict_to_inst(data_dict)
	const FALLING_BOX = preload("uid://b6hwok27qogib")
	var box: FallingBox = FALLING_BOX.instantiate()
	box.global_position = spawn_data.position
	box.reset_physics_interpolation()
	return box
