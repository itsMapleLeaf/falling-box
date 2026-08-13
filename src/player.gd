class_name Player
extends CharacterBody2D

signal respawned(at_position: Vector2)
signal died

const MAX_JUMPS := 2
const HELD_BLOCK_STIFFNESS := 17.0

@export var level: Level
@export var facing := 1
@export var holding := false

var movement := 0.0
var jumps_requested := 0
var jumps_remaining := MAX_JUMPS
var respawn_rng := RandomNumberGenerator.new()
var is_dead := false
var active_collision_layer: int
var active_collision_mask: int
var is_local := false

@onready var cursor_root: Node2D = %CursorRoot
@onready var cursor: Node2D = %Cursor
@onready var crush_detector_top: Area2D = %CrushDetectorTop
@onready var crush_detector_bottom: Area2D = %CrushDetectorBottom
@onready var camera: Camera2D = %Camera
@onready var respawn_timer: Timer = %RespawnTimer
@onready var name_tag: Label = %NameTag
@onready var held_block: Node2D = %HeldBlock

var respawn_delay: float:
	set(value):
		respawn_timer.wait_time = value


func _ready() -> void:
	active_collision_layer = collision_layer
	active_collision_mask = collision_mask
	respawn_rng.randomize()
	respawn()

	camera.enabled = is_multiplayer_authority()


func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return

	var direction := Input.get_axis("move_left", "move_right")

	movement = direction
	if not is_zero_approx(direction):
		facing = 1 if direction > 0.0 else -1

	if event.is_action_pressed("jump"):
		jumps_requested += 1

	if event.is_action_pressed("grab"):
		grab()

	if event.is_action_released("grab"):
		release()


func set_name_tag_text(text: String) -> void:
	name_tag.text = text


func _process(_delta: float) -> void:
	cursor_root.scale.x = facing
	_update_holding_display()


func _update_holding_display() -> void:
	if holding:
		cursor.visible = false
		held_block.visible = true
	else:
		cursor.visible = true
		held_block.visible = false


func _physics_process(delta: float) -> void:
	velocity.x = lerpf(
		velocity.x,
		movement * GameConfig.RUN_SPEED,
		GameConfig.MOVEMENT_STIFFNESS * delta,
	)

	if is_on_floor():
		jumps_remaining = MAX_JUMPS
	else:
		velocity.y = minf(velocity.y + GameConfig.PLAYER_GRAVITY * delta, GameConfig.MAX_FALL_SPEED)

	while jumps_requested > 0:
		jumps_requested -= 1
		if jumps_remaining > 0:
			velocity.y = GameConfig.JUMP_VELOCITY
			jumps_remaining -= 1

	move_and_slide()

	if _is_squished_by_falling_box():
		die()
		return

	if is_on_floor():
		jumps_remaining = MAX_JUMPS

	if global_position.y > level.player_fallout.global_position.y:
		die()

	held_block.global_position = held_block.global_position.lerp(
		cursor.global_position,
		delta * HELD_BLOCK_STIFFNESS,
	)


func _is_squished_by_falling_box() -> bool:
	return (
		crush_detector_top.has_overlapping_bodies()
		and crush_detector_bottom.has_overlapping_bodies()
	)


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
	release()

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


func grab() -> void:
	if holding:
		return

	var params := PhysicsPointQueryParameters2D.new()
	params.position = cursor.global_position

	var results := get_world_2d().direct_space_state.intersect_point(params)
	for result in results:
		var box := result['collider'] as FallingBox
		if box:
			#resolve_grab.rpc(box.global_position)
			held_block.global_position = box.global_position
			held_block.reset_physics_interpolation()
			holding = true
			_update_holding_display()
			box.remove_grabbed.rpc()
			return


func release() -> void:
	if not holding:
		return

	holding = false
	_update_holding_display()
	# TODO: create flying block
