class_name Explosion
extends GPUParticles2D


static func explode(node: Node2D) -> void:
	const EXPLOSION = preload("uid://b47038mcmvy10")
	var explosion: Node2D = EXPLOSION.instantiate()
	explosion.global_position = node.global_position

	node.add_sibling(explosion)

	if node.is_multiplayer_authority():
		node.queue_free()


func _ready() -> void:
	emitting = true


func _on_finished() -> void:
	queue_free()
