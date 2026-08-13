class_name Explosion
extends GPUParticles2D


static func spawn(node: Node2D) -> void:
	const EXPLOSION = preload("uid://b47038mcmvy10")
	var explosion: Node2D = EXPLOSION.instantiate()
	explosion.global_position = node.global_position
	node.add_sibling(explosion)


static func destroy(node: Node2D) -> void:
	spawn(node)
	if node.is_multiplayer_authority():
		node.queue_free()
	else:
		node.visible = false


func _ready() -> void:
	emitting = true


func _on_finished() -> void:
	queue_free()
