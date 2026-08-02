class_name FallingBlock
extends CharacterBody2D

const GRAVITY = 800.0
const TERMINAL_VELOCITY = 600.0
const MAX_LIFETIME = 15.0

var lifetime: float

@onready var sprite: MeshInstance2D = %Sprite
@onready var collision_shape: CollisionShape2D = %CollisionShape


func _ready() -> void:
	if not multiplayer.is_server():
		return

	lifetime = MAX_LIFETIME
	sprite.modulate.a = 0


func _process(delta: float) -> void:
	if not multiplayer.is_server():
		return

	lifetime -= delta
	if lifetime > 0:
		sprite.modulate.a = minf(sprite.modulate.a + delta, 1)
	if lifetime < 0:
		sprite.modulate.a = maxf(sprite.modulate.a - delta, 0)
		collision_layer = 0
		collision_mask = 0
		if sprite.modulate.a == 0:
			queue_free()


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return

	velocity.y = clampf(
			velocity.y + GRAVITY * delta,
			-TERMINAL_VELOCITY,
			TERMINAL_VELOCITY,
	)
	move_and_slide()
