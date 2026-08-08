class_name Player
extends CharacterBody2D

signal respawned(at_position: Vector2)
signal died

const CURSOR_OFFSET := 55.0
const MAX_JUMPS := 2

@export var cursor: MeshInstance2D
@export var fallout_threshold: Marker2D
@export var respawn_left: Marker2D
@export var respawn_right: Marker2D
@export var camera: Camera2D
@export var crush_detector: Area2D

var facing := 1
var jumps_remaining := MAX_JUMPS
var respawn_rng := RandomNumberGenerator.new()


func _ready() -> void:
	respawn_rng.randomize()
	respawn()


func _process(_delta: float) -> void:
	cursor.position.x = facing * CURSOR_OFFSET
	cursor.reset_physics_interpolation()


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

	if (
		fallout_threshold != null and respawn_left != null and respawn_right != null
		and global_position.y > fallout_threshold.global_position.y
	):
		respawn()


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
	died.emit()
	respawn()


func respawn() -> void:
	var minimum_x := minf(respawn_left.global_position.x, respawn_right.global_position.x)
	var maximum_x := maxf(respawn_left.global_position.x, respawn_right.global_position.x)
	var at_position := Vector2(
		respawn_rng.randf_range(minimum_x, maximum_x),
		respawn_left.global_position.y,
	)
	global_position = at_position
	velocity = Vector2.ZERO
	jumps_remaining = MAX_JUMPS
	reset_physics_interpolation()
	respawned.emit(at_position)
