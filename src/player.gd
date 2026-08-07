class_name Player
extends CharacterBody2D

const CURSOR_DISTANCE := 25.0
const MAX_JUMPS := 2

@onready var cursor: MeshInstance2D = $Cursor

var facing := 1
var jumps_remaining := MAX_JUMPS


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")

	if not is_zero_approx(direction):
		facing = 1 if direction > 0.0 else -1
		cursor.position.x = facing * (
			GameConfig.PLAYER_SIZE.x * 0.5 + CURSOR_DISTANCE
		)

	velocity.x = move_toward(
		velocity.x,
		direction * GameConfig.RUN_SPEED,
		GameConfig.ACCELERATION * delta
	)

	if is_on_floor():
		jumps_remaining = MAX_JUMPS
	else:
		velocity.y = minf(
			velocity.y + GameConfig.GRAVITY * delta,
			GameConfig.MAX_FALL_SPEED
		)

	if Input.is_action_just_pressed("jump") and jumps_remaining > 0:
		velocity.y = GameConfig.JUMP_VELOCITY
		jumps_remaining -= 1

	move_and_slide()

	if is_on_floor():
		jumps_remaining = MAX_JUMPS
