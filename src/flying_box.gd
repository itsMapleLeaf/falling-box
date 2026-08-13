class_name FlyingBox
extends Area2D

const SPEED = 700.0

@export var facing: Facing.Facing = Facing.Facing.RIGHT
@export var owner_player_id: int = 0


func _ready() -> void:
	set_physics_process(is_multiplayer_authority())


func _physics_process(delta: float) -> void:
	position.x += facing * SPEED * delta


func _on_death_timer_timeout() -> void:
	queue_free()
