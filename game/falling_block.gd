extends CharacterBody2D

@export var gravity: float
@export var terminal_velocity: float

@export var max_lifetime: float
var lifetime: float

@onready var sprite: ColorRect = %ColorRect
@onready var collision_shape: CollisionShape2D = %CollisionShape


func _ready() -> void:
	lifetime = max_lifetime
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
		velocity.y + gravity * delta,
		-terminal_velocity,
		terminal_velocity,
	)
	move_and_slide()
