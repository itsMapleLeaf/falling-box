class_name FallingBox
extends CharacterBody2D

signal grounded
signal expiring

enum State {
	FALLING,
	GROUNDED,
	EXPIRING,
}

@export var visual: Node2D
@export var hitbox: CollisionShape2D
@export var spawn_fade_seconds := GameConfig.BOX_SPAWN_FADE_SECONDS
@export var despawn_fade_seconds := GameConfig.LANDED_BOX_FADE_SECONDS

var state := State.FALLING
var grounded_age := 0.0
var spawn_fade_age := 0.0
var despawn_fade_age := 0.0

@onready var expiration: Timer = %ExpiryTimer


func _ready() -> void:
	set_physics_process(is_multiplayer_authority())

	modulate.a = 0
	create_tween().tween_property(self, "modulate:a", 1, spawn_fade_seconds)

	if is_multiplayer_authority():
		expiration.start()


func _physics_process(delta: float) -> void:
	if state == State.FALLING:
		_apply_gravity(delta)
		move_and_slide()
		if is_on_floor():
			_land()

	if state == State.EXPIRING:
		_apply_gravity(delta)
		position += velocity * delta


func _apply_gravity(delta: float) -> void:
	velocity.y = minf(velocity.y + GameConfig.BOX_GRAVITY * delta, GameConfig.BOX_MAX_FALL_SPEED)


func _land() -> void:
	state = State.GROUNDED
	velocity = Vector2.ZERO
	global_position = global_position.snapped(Vector2.ONE * GameConfig.CELL_SIZE)
	reset_physics_interpolation()
	grounded.emit()
	Tremble.trigger(Tremble.intensity_tiny)


func _on_expiration_timeout() -> void:
	state = State.EXPIRING
	velocity = Vector2.ZERO
	expiring.emit()
	_expire.rpc()


@rpc("call_local")
func _expire() -> void:
	modulate.a = 1
	hitbox.set_deferred("disabled", true)
	await create_tween().tween_property(self, "modulate:a", 0, despawn_fade_seconds).finished
	queue_free()


@rpc("any_peer", "call_local")
func remove_grabbed() -> void:
	queue_free()


@rpc("any_peer", "call_local")
func destroy() -> void:
	Explosion.destroy(self)
	Tremble.trigger(Tremble.intensity_minor)
