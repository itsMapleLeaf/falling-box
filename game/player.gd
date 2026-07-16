extends CharacterBody2D

@export var move_speed := 500.0
@export var move_accel := 10.0

@export var gravity := 2500.0

@export var jump_strength := 700.0
var jumps := 2


func _ready() -> void:
	velocity = Vector2(0, 100)


func _physics_process(delta: float) -> void:
	velocity += gravity * Vector2.DOWN * delta

	# intentionally allows jumping twice after walking off a ledge - more fun this way!
	if is_on_floor():
		jumps = 2

	if Input.is_action_just_pressed("jump") and jumps > 0:
		velocity.y = -jump_strength
		jumps -= 1

	velocity.x = lerpf(
		velocity.x,
		Input.get_axis("move_left", "move_right") * move_speed,
		clampf(move_accel * delta, 0, 1),
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
