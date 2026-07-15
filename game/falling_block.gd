extends CharacterBody2D

@export var gravity := 800.0
@export var terminal_velocity := 300.0


func _physics_process(delta: float) -> void:
	velocity.y += clampf(gravity * delta, -terminal_velocity, terminal_velocity)
	move_and_slide()
