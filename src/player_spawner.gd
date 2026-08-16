class_name PlayerSpawner
extends MultiplayerSpawner

@export var game: Game
@export var flying_box_spawner: FlyingBoxSpawner


class PlayerSpawnData:
	var peer_id: int = 1
	var alias: String = "You"


	func pack() -> Dictionary:
		return { "peer_id": peer_id, "alias": alias }


	static func unpack(data: Dictionary) -> PlayerSpawnData:
		var result := PlayerSpawnData.new()
		result.peer_id = data.get("peer_id", 1)
		result.alias = data.get("alias", "You")
		return result


func _ready() -> void:
	spawn_function = _create_spawned_player


func _create_spawned_player(data_dict: Dictionary):
	var data: PlayerSpawnData = dict_to_inst(data_dict)

	const PLAYER = preload("uid://dgfxlv2n2qtvd")
	var player: Player = PLAYER.instantiate()
	player.level = game.level
	player.alias = data.alias
	player.set_multiplayer_authority(data.peer_id)
	player.released.connect(_on_player_released)
	game.players_by_peer_id[data.peer_id] = player

	return player


# there's probably a better way to do this
func _on_player_released(player_id: int, at_position: Vector2, facing: Facing.Facing) -> void:
	create_flying_block.rpc(player_id, at_position, facing)


@rpc("any_peer", "call_local")
func create_flying_block(player_id: int, at_position: Vector2, facing: Facing.Facing) -> void:
	if multiplayer.is_server():
		var data := FlyingBoxSpawner.FlyingBoxData.new()
		data.owner_player_id = player_id
		data.position = at_position
		data.facing = facing
		flying_box_spawner.spawn_flying_box(data)
