class_name FallingBlock
extends CharacterBody2D

const GRAVITY = 800.0
const TERMINAL_VELOCITY = 600.0
const MAX_LIFETIME = 15.0

var lifetime: float

@onready var sprite: ColorRect = %ColorRect
@onready var collision_shape: CollisionShape2D = %CollisionShape


func _ready() -> void:
	lifetime = MAX_LIFETIME
	sprite.color.a = 0


func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime > 0:
		sprite.color.a = minf(sprite.color.a + delta, 1)
	if lifetime < 0:
		sprite.color.a = maxf(sprite.color.a - delta, 0)
		collision_layer = 0
		collision_mask = 0
		if sprite.color.a == 0:
			queue_free()


func _physics_process(delta: float) -> void:
	velocity.y = clampf(
			velocity.y + GRAVITY * delta,
			-TERMINAL_VELOCITY,
			TERMINAL_VELOCITY,
	)
	move_and_slide()
