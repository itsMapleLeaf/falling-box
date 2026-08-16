class_name Player
extends CharacterBody2D

signal respawned(at_position: Vector2)
signal died
signal released(player_id: int, at_position: Vector2, facing: Facing.Facing)

const MAX_JUMPS := 2
const HELD_BLOCK_STIFFNESS := 17.0
const INTANGIBLE_TIME := 3.0
const INTANGIBLE_BLINK_PERIOD := 0.5

@export var is_dead := false
@export var player_id: int = randi()
@export var level: Level
@export var facing := Facing.Facing.RIGHT
@export var holding := false
@export var alias: String = ""

var movement := 0.0
var jumps_requested := 0
var jumps_remaining := MAX_JUMPS
var respawn_rng := RandomNumberGenerator.new()
var active_collision_layer: int
var active_collision_mask: int
var is_local := false
var intangible_time := 0.0

@onready var cursor_root: Node2D = %CursorRoot
@onready var cursor: Node2D = %Cursor
@onready var crush_detector_top: Area2D = %CrushDetectorTop
@onready var crush_detector_bottom: Area2D = %CrushDetectorBottom
@onready var camera: Camera2D = %Camera
@onready var respawn_timer: Timer = %RespawnTimer
@onready var name_tag: Label = %NameTag
@onready var held_block: Node2D = %HeldBlock
@onready var body: MeshInstance2D = %Body

var respawn_delay: float:
	set(value):
		respawn_timer.wait_time = value

## True if the player can move around and interact with the world
var is_alive: bool:
	get ():
		return !is_dead

## True if the player is currently intangible and cannot be hit by boxes
## (but can still be crushed and fall out of the level)
var is_intangible: bool:
	get ():
		return intangible_time > 0

## True if the player can be killed by flying boxes
var is_killable: bool:
	get ():
		return is_alive and not is_intangible


func _ready() -> void:
	active_collision_layer = collision_layer
	active_collision_mask = collision_mask

	name_tag.text = alias

	camera.enabled = is_multiplayer_authority()

	respawn_rng.randomize()
	respawn()


func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return

	if event.is_action_pressed("jump"):
		jumps_requested += 1

	if event.is_action_pressed("grab"):
		grab()

	if event.is_action_released("grab"):
		release()


func set_name_tag_text(text: String) -> void:
	name_tag.text = text


func _process(delta: float) -> void:
	cursor_root.scale.x = facing
	_update_holding_display()

	if is_intangible:
		var alpha_normal := inverse_lerp(
			-1,
			1,
			sin(Time.get_ticks_msec() / 100.0 / INTANGIBLE_BLINK_PERIOD),
		)
		body.modulate.a = lerpf(0.2, 1, alpha_normal)
		intangible_time -= delta
		if intangible_time <= 0.0:
			intangible_time = 0.0
	else:
		body.modulate.a = 1.0


func _update_holding_display() -> void:
	if holding:
		cursor.visible = false
		held_block.visible = true
	else:
		cursor.visible = true
		held_block.visible = false


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		movement = Input.get_axis("move_left", "move_right")
		if not is_zero_approx(movement):
			facing = int(signf(movement)) as Facing.Facing

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
		die.rpc()
		return

	if is_on_floor():
		jumps_remaining = MAX_JUMPS

	if global_position.y > level.player_fallout.global_position.y:
		die.rpc()

	held_block.global_position = held_block.global_position.lerp(
		cursor.global_position,
		delta * HELD_BLOCK_STIFFNESS,
	)


func _is_squished_by_falling_box() -> bool:
	return (
		crush_detector_top.has_overlapping_bodies()
		and crush_detector_bottom.has_overlapping_bodies()
	)


@rpc('any_peer', 'call_local')
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
	release()
	Tremble.trigger(Tremble.intensity_major)
	Explosion.spawn(self)
	died.emit()


func respawn() -> void:
	global_position = level.get_random_player_spawn_position()
	velocity = Vector2.ZERO
	jumps_remaining = MAX_JUMPS
	collision_layer = active_collision_layer
	collision_mask = active_collision_mask
	visible = true
	is_dead = false
	intangible_time = INTANGIBLE_TIME
	set_physics_process(true)
	reset_physics_interpolation()
	respawned.emit(global_position)


func _on_respawn_timer_timeout() -> void:
	respawn()


func grab() -> void:
	if not is_alive:
		return

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
			box.visible = false
			box.remove_grabbed.rpc_id(1)
			return


func release() -> void:
	if not holding:
		return

	holding = false
	_update_holding_display()
	released.emit(player_id, held_block.global_position, facing)
