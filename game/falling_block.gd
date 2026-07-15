extends AnimatableBody2D

enum State {
	FALLING, # Just spawned, currently falling
	STATIC, # Hit the ground, or another block, and can be grabbed
	GHOST, # Has reached max lifetime, and is fading out
}

var state := State.FALLING
var velocity := Vector2.ZERO
@export var gravity := 2500.0
@export var terminal_velocity := 400.0


func _physics_process(delta: float) -> void:
	match state:
		State.FALLING:
			_handle_falling_state(delta)
		State.STATIC:
			pass
		State.GHOST:
			pass


func _handle_falling_state(delta: float) -> void:
	velocity.y += clampf(gravity * delta, -terminal_velocity, terminal_velocity)
	position += velocity

	if _has_static_block_below():
		state = State.STATIC
		velocity = Vector2.ZERO


func _has_static_block_below() -> bool:
	## todo
	return false
