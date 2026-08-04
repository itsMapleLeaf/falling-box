class_name Player
extends CharacterBody2D

signal block_yeeted(player: Player, at: Vector2, direction: int)

const MOVE_SPEED = 500.0
const MOVE_ACCEL = 10.0
const GRAVITY = 2500.0
const JUMP_STRENGTH = 750.0
const HELD_BLOCK_INTERPOLATION_STIFFNESS = 20.0
const SPAWN_HEIGHT = 500

var jumps := 2

## variable for the input handler to communicate to the process loop that a jump is desired,
## to ensure the correct order of jumps and jump resets, e.g. so we don't accidentally get extra jumps
var jump_queued := false

var movement := 0
@export var facing := 1
@export var holding := false

@onready var facing_dot: MeshInstance2D = %FacingDot
@onready var facing_dot_offset := facing_dot.position

@onready var held_block: MeshInstance2D = %HeldBlock
@onready var held_block_offset := held_block.position

# we don't want the held block position to be fixed with the parent,
# but to move as if it's still in the global environment, and we're "dragging" it along,
# so we manually track and apply an interpolated global position to accomplish that
@onready var held_block_target_global_position := held_block.global_position

@onready var camera: Camera2D = $Camera2D


func _enter_tree() -> void:
	set_multiplayer_authority(int(name))


func _ready() -> void:
	camera.enabled = is_multiplayer_authority()

	# crimes
	global_position = Vector2(
		(
			randi_range(Globals.default_level.bounds.position.x, Globals.default_level.bounds.end.x)
			- float(Globals.default_level.bounds.size.x) / 2
		)
		* Globals.LEVEL_CELL_SIZE,
		-SPAWN_HEIGHT,
	)


func _unhandled_input(event: InputEvent) -> void:
	if is_multiplayer_authority() and get_window().has_focus():
		movement = int(signf(Input.get_axis("move_left", "move_right")))

		if movement != 0:
			facing = movement

		if event.is_action_pressed("grab") and not holding:
			var query := PhysicsPointQueryParameters2D.new()
			query.position = facing_dot.global_position

			var results := get_world_2d().direct_space_state.intersect_point(query, 32)
			for result in results:
				var block := result['collider'] as FallingBlock
				if block:
					holding = true
					held_block.global_position = block.global_position
					held_block_target_global_position = held_block.global_position
					block.queue_free()
					break

		if event.is_action_released("grab") and holding:
			holding = false
			block_yeeted.emit(self, held_block.global_position, facing)

		if event.is_action_pressed("jump") and jumps > 0:
			jump_queued = true


func _process(_delta: float) -> void:
	facing_dot.position = facing * facing_dot_offset
	facing_dot.visible = not holding
	held_block.visible = holding


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		velocity += GRAVITY * Vector2.DOWN * delta

		# intentionally allows jumping twice after walking off a ledge - more fun this way!
		if is_on_floor():
			jumps = 2

		if jump_queued:
			jump_queued = false
			if jumps > 0:
				velocity.y = -JUMP_STRENGTH
				jumps -= 1

		_move_colliding(delta)
		_reposition_held_block(delta)


func _move_colliding(delta: float):
	velocity.x = lerpf(velocity.x, movement * MOVE_SPEED, clampf(MOVE_ACCEL * delta, 0, 1))

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
