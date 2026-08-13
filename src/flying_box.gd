class_name FlyingBox
extends Area2D

const SPEED = 700.0

@export var facing: Facing.Facing = Facing.Facing.RIGHT
@export var owner_player_id: int = 0

var hits := 2


func _ready() -> void:
	set_physics_process(is_multiplayer_authority())


func _physics_process(delta: float) -> void:
	position.x += facing * SPEED * delta


func _on_death_timer_timeout() -> void:
	if is_inside_tree():
		destroy.rpc()


@rpc("any_peer", "call_local")
func destroy() -> void:
	Explosion.destroy(self)


func _on_body_entered(body: Node2D) -> void:
	if body is FallingBox:
		if hits > 0:
			hits -= 1
			body.destroy.rpc()
		else:
			destroy.rpc()

	if body is Player and body.player_id != owner_player_id:
		body.die.rpc()
