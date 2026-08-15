class_name FlyingBox
extends Area2D

const SPEED = 700.0
const HIT_FREEZE_TIME = 0.1

@export var facing: Facing.Facing = Facing.Facing.RIGHT
@export var owner_player_id := 0

var hits := 2
var freeze_time := 0.0
var hit_queue: Array[FallingBox] = []


func _ready() -> void:
	set_physics_process(is_multiplayer_authority())


func _physics_process(delta: float) -> void:
	if freeze_time > 0:
		freeze_time -= delta
		return

	position.x += facing * SPEED * delta

	var hit: FallingBox = hit_queue.pop_front()
	if hit:
		_handle_hit(hit)


func _handle_hit(box: FallingBox) -> void:
	if hits > 0:
		hits -= 1
		box.destroy.rpc()
		freeze_time = HIT_FREEZE_TIME
	else:
		destroy.rpc()


func _on_death_timer_timeout() -> void:
	if is_inside_tree():
		destroy.rpc()


@rpc("any_peer", "call_local")
func destroy() -> void:
	Explosion.destroy(self)
	Tremble.trigger(Tremble.intensity_moderate)


func _on_body_entered(body: Node2D) -> void:
	if freeze_time > 0:
		return

	if body is FallingBox:
		hit_queue.append(body)

	if body is Player and body.is_killable && body.player_id != owner_player_id:
		body.die.rpc()
