class_name FlyingBlock
extends Area2D

const MAX_LIFETIME = 1.0
const SPEED = 700.0

var lifetime := MAX_LIFETIME
var direction := 1
var hits := 2

@onready var sprite: MeshInstance2D = %Sprite


func _process(delta: float) -> void:
	if not multiplayer.is_server():
		return

	lifetime -= delta
	if lifetime < 0:
		queue_free()
		# TODO: add particle explosion


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return

	global_position += Vector2(SPEED, 0) * direction * delta


func _on_body_entered(body: Node2D) -> void:
	if not multiplayer.is_server():
		return

	if body is FallingBlock:
		if hits > 0:
			body.queue_free()
			hits -= 1
		else:
			queue_free()
