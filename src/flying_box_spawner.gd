class_name FlyingBoxSpawner
extends MultiplayerSpawner

const FLYING_BOX = preload("uid://c6xpnt13peisa")


class FlyingBoxData:
	var position: Vector2
	var facing: Facing.Facing = Facing.Facing.RIGHT
	var owner_player_id: int


func _init() -> void:
	spawn_function = _spawn_function


func _spawn_function(data_dict: Dictionary) -> FlyingBox:
	var box: FlyingBox = FLYING_BOX.instantiate()
	var data: FlyingBoxData = dict_to_inst(data_dict)
	box.global_position = data.position
	box.facing = data.facing
	box.owner_player_id = data.owner_player_id
	return box


func spawn_flying_box(data: FlyingBoxData) -> FlyingBox:
	var data_dict: Dictionary = inst_to_dict(data)
	return spawn(data_dict)
