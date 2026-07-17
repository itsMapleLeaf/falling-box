class_name Player
extends CharacterBody2D

signal yeeted(player: Player, at: Vector2, direction: int)

const MOVE_SPEED = 500.0
const MOVE_ACCEL = 10.0
const GRAVITY = 2500.0
const JUMP_STRENGTH = 750.0
const HELD_BLOCK_INTERPOLATION_STIFFNESS = 20.0

var jumps := 2
var facing := 1
var holding := false

@onready var facing_dot: MeshInstance2D = %FacingDot
@onready var facing_dot_offset := facing_dot.position - position

@onready var held_block: MeshInstance2D = %HeldBlock
@onready var held_block_offset := held_block.position - position

# we don't want the held block position to be fixed with the parent,
# but to move as if it's still in the global environment, and we're "dragging" it along,
# so we manually track and apply an interpolated global position to accomplish that
@onready var held_block_target_global_position := held_block.global_position


func _ready() -> void:
	velocity = Vector2(0, 100)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left"):
		facing = -1
		facing_dot.position = -facing_dot_offset

	if event.is_action_pressed("move_right"):
		facing = 1
		facing_dot.position = facing_dot_offset

	if event.is_action_pressed("grab") and not holding:
		var query := PhysicsPointQueryParameters2D.new()
		query.position = facing_dot.global_position

		var results := get_world_2d().direct_space_state.intersect_point(query, 32)
		for result in results:
			var block := result['collider'] as FallingBlock
			if block:
				holding = true
				facing_dot.visible = false
				held_block.visible = true
				held_block.global_position = block.global_position
				held_block_target_global_position = held_block.global_position
				block.queue_free()
				break

	if event.is_action_released("grab") and holding:
		holding = false
		facing_dot.visible = true
		held_block.visible = false
		yeeted.emit(held_block.global_position, facing)


func _physics_process(delta: float) -> void:
	velocity += GRAVITY * Vector2.DOWN * delta

	_handle_jumping()
	_move_colliding(delta)
	_reposition_held_block(delta)


func _handle_jumping():
	# intentionally allows jumping twice after walking off a ledge - more fun this way!
	if is_on_floor():
		jumps = 2

	if Input.is_action_just_pressed("jump") and jumps > 0:
		velocity.y = -JUMP_STRENGTH
		jumps -= 1


func _move_colliding(delta: float):
	velocity.x = lerpf(
			velocity.x,
			Input.get_axis("move_left", "move_right") * MOVE_SPEED,
			clampf(MOVE_ACCEL * delta, 0, 1),
	)

	move_and_slide()

	var has_top_collision := false
	var has_bottom_collision := false

	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var angle := collision.get_angle(Vector2.RIGHT)

		if is_equal_approx(angle, Vector2.UP.angle()):
			has_top_collision = true

		if is_equal_approx(angle, Vector2.DOWN.angle()):
			has_bottom_collision = true

		if has_top_collision and has_bottom_collision:
			print("death")


func _reposition_held_block(delta: float):
	if holding:
		held_block_target_global_position = held_block_target_global_position.lerp(
				global_position + held_block_offset * facing,
				clampf(delta * HELD_BLOCK_INTERPOLATION_STIFFNESS, 0, 1),
		)
		held_block.global_position = held_block_target_global_position
