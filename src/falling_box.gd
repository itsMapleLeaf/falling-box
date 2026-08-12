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
@export var landed_lifetime_seconds := GameConfig.LANDED_BOX_LIFETIME_SECONDS
@export var despawn_fade_seconds := GameConfig.LANDED_BOX_FADE_SECONDS

var state := State.FALLING
var grounded_age := 0.0
var spawn_fade_age := 0.0
var despawn_fade_age := 0.0


func _enter_tree() -> void:
	set_physics_process(is_multiplayer_authority())


func _ready() -> void:
	visual.modulate.a = 0.0


func _physics_process(delta: float) -> void:
	_update_spawn_fade(delta)

	match state:
		State.FALLING:
			_fall_with_collision(delta)
		State.GROUNDED:
			_update_grounded(delta)
		State.EXPIRING:
			_update_expiring(delta)


func _update_spawn_fade(delta: float) -> void:
	if state == State.EXPIRING or visual.modulate.a >= 1.0:
		return

	spawn_fade_age += delta
	if spawn_fade_seconds <= 0.0:
		visual.modulate.a = 1.0
	else:
		visual.modulate.a = minf(spawn_fade_age / spawn_fade_seconds, 1.0)


func _fall_with_collision(delta: float) -> void:
	velocity.y = minf(velocity.y + GameConfig.BOX_GRAVITY * delta, GameConfig.BOX_MAX_FALL_SPEED)
	move_and_slide()

	if is_on_floor():
		_land()


func _land() -> void:
	state = State.GROUNDED
	velocity = Vector2.ZERO
	global_position = global_position.snapped(Vector2.ONE * GameConfig.CELL_SIZE)
	reset_physics_interpolation()
	grounded.emit()
	Tremble.trigger(5)


func _update_grounded(delta: float) -> void:
	grounded_age += delta
	if grounded_age >= landed_lifetime_seconds:
		_begin_expiring()


func _begin_expiring() -> void:
	state = State.EXPIRING
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	hitbox.set_deferred("disabled", true)
	expiring.emit()


func _update_expiring(delta: float) -> void:
	despawn_fade_age += delta
	velocity.y = minf(velocity.y + GameConfig.BOX_GRAVITY * delta, GameConfig.BOX_MAX_FALL_SPEED)
	global_position += velocity * delta

	if despawn_fade_seconds <= 0.0:
		visual.modulate.a = 0.0
	else:
		visual.modulate.a = maxf(1.0 - despawn_fade_age / despawn_fade_seconds, 0.0)

	if visual.modulate.a <= 0.0:
		queue_free()
