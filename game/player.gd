extends CharacterBody2D

const MOVE_SPEED = 500.0
const MOVE_ACCEL = 10.0
const GRAVITY = 2500.0
const JUMP_STRENGTH = 700.0

var jumps := 2
var facing := 1

@onready var facing_dot: MeshInstance2D = $FacingDot
@onready var facing_dot_distance := facing_dot.position.x - position.x


func _ready() -> void:
	velocity = Vector2(0, 100)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left"):
		facing = -1
		facing_dot.position = facing_dot_distance * Vector2.LEFT

	if event.is_action_pressed("move_right"):
		facing = 1
		facing_dot.position = facing_dot_distance * Vector2.RIGHT


func _physics_process(delta: float) -> void:
	velocity += GRAVITY * Vector2.DOWN * delta

	# intentionally allows jumping twice after walking off a ledge - more fun this way!
	if is_on_floor():
		jumps = 2

	if Input.is_action_just_pressed("jump") and jumps > 0:
		velocity.y = -JUMP_STRENGTH
		jumps -= 1

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
