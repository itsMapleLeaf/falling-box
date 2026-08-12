class_name Player
extends CharacterBody2D

signal respawned(at_position: Vector2)
signal died

const MAX_JUMPS := 2

@export var level: Level

@onready var cursor_root: Node2D = %CursorRoot
@onready var crush_detector: Area2D = %CrushDetector
@onready var camera: Camera2D = %Camera
@onready var respawn_timer: Timer = %RespawnTimer

var facing := 1
var jumps_remaining := MAX_JUMPS
var respawn_rng := RandomNumberGenerator.new()
var is_dead := false
var active_collision_layer: int
var active_collision_mask: int
var is_local := false


func _enter_tree() -> void:
	set_multiplayer_authority(int(name))


func _ready() -> void:
	active_collision_layer = collision_layer
	active_collision_mask = collision_mask
	respawn_rng.randomize()
	respawn()
	camera.enabled = is_multiplayer_authority() || is_local


func _process(_delta: float) -> void:
	cursor_root.scale.x = facing


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")

	if not is_zero_approx(direction):
		facing = 1 if direction > 0.0 else -1

	velocity.x = move_toward(
		velocity.x,
		direction * GameConfig.RUN_SPEED,
		GameConfig.ACCELERATION * delta,
	)

	if is_on_floor():
		jumps_remaining = MAX_JUMPS
	else:
		velocity.y = minf(velocity.y + GameConfig.PLAYER_GRAVITY * delta, GameConfig.MAX_FALL_SPEED)

	if Input.is_action_just_pressed("jump") and jumps_remaining > 0:
		velocity.y = GameConfig.JUMP_VELOCITY
		jumps_remaining -= 1

	move_and_slide()

	if _is_squished_by_falling_box():
		die()
		return

	if is_on_floor():
		jumps_remaining = MAX_JUMPS

	if (global_position.y > level.player_fallout.global_position.y):
		die()


func _is_squished_by_falling_box() -> bool:
	if not is_on_floor():
		return false

	var body_above := false
	var body_below := false

	for body in crush_detector.get_overlapping_bodies():
		body_above = body_above or body.global_position.y < global_position.y
		body_below = body_below or body.global_position.y > global_position.y
		if body_above and body_below:
			return true

	return false


func die() -> void:
	if is_dead:
		return

	is_dead = true
	visible = false
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	set_physics_process(false)
	respawn_timer.start()
	died.emit()
	Tremble.trigger(100)

	const EXPLOSION = preload("uid://b47038mcmvy10")
	var explosion: GPUParticles2D = EXPLOSION.instantiate()
	add_sibling(explosion)
	explosion.global_position = global_position


func respawn() -> void:
	global_position = level.get_random_player_spawn_position()
	velocity = Vector2.ZERO
	jumps_remaining = MAX_JUMPS
	collision_layer = active_collision_layer
	collision_mask = active_collision_mask
	visible = true
	is_dead = false
	set_physics_process(true)
	reset_physics_interpolation()
	respawned.emit(global_position)


func _on_respawn_timer_timeout() -> void:
	respawn()
