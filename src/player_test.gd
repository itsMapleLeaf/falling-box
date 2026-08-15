extends GutTest

const GameScene := preload("res://src/game/game.tscn")

var game: Game
var player: Player


func before_each() -> void:
	game = add_child_autofree(GameScene.instantiate())
	player = game.create_player()
	game.add_child(player)
	await wait_physics_frames(5)


func after_each() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")


func _get_player_visual_facing() -> int:
	return int(player.cursor_root.scale.x)


func test_player_moves_right_and_faces_right() -> void:
	var starting_x := player.position.x

	Input.action_press("move_right")
	await wait_physics_frames(12)
	Input.action_release("move_right")

	assert_gt(player.position.x, starting_x, "Player should move to the right")
	assert_eq(player.facing, 1, "Player should face right while moving right")
	assert_eq(_get_player_visual_facing(), 1, "Cursor should appear on the right")


func test_player_moves_left_and_faces_left() -> void:
	var starting_x := player.position.x

	Input.action_press("move_left")
	await wait_physics_frames(12)
	Input.action_release("move_left")

	assert_lt(player.position.x, starting_x, "Player should move to the left")
	assert_eq(player.facing, -1, "Player should face left while moving left")
	assert_eq(_get_player_visual_facing(), -1, "Cursor should appear on the left")


func test_player_keeps_facing_right_after_movement_stops() -> void:
	Input.action_press("move_right")
	await wait_physics_frames(12)
	Input.action_release("move_right")
	await wait_physics_frames(2)

	assert_eq(player.facing, 1, "Neutral input should preserve the last facing direction")
	assert_eq(_get_player_visual_facing(), 1, "Cursor should remain on the facing side")


func test_player_can_double_jump_but_not_triple_jump() -> void:
	# TODO: wait until the player is on the ground
	#assert_true(player.is_on_floor(), "Player should begin on the platform")
	await _press_jump()
	assert_lt(player.velocity.y, 0.0, "First jump should launch the player upward")
	assert_eq(player.jumps_remaining, 1, "First jump should consume one jump")

	await wait_physics_frames(5)
	await _press_jump()
	assert_lt(player.velocity.y, 0.0, "Second jump should relaunch the player upward")
	assert_eq(player.jumps_remaining, 0, "Second jump should consume the last jump")

	var velocity_before_third_attempt := player.velocity.y
	await _press_jump()
	assert_eq(player.jumps_remaining, 0, "A third jump should not be available")
	assert_gt(
		player.velocity.y,
		velocity_before_third_attempt,
		"A third jump should not reset upward velocity",
	)


func test_landing_restores_both_jumps() -> void:
	await _press_jump()
	await wait_physics_frames(5)
	await _press_jump()

	await wait_physics_frames(120)

	assert_true(player.is_on_floor(), "Player should land back on the platform")
	assert_eq(player.jumps_remaining, 2, "Landing should restore both jumps")


func test_falling_far_past_the_threshold_respawns_player_above_platform() -> void:
	player.respawn_delay = 0.1
	watch_signals(player)
	var velocity_at_respawn := [Vector2.INF]
	player.respawned.connect(
		func(_at_position: Vector2) -> void:
			velocity_at_respawn[0] = player.velocity,
		CONNECT_ONE_SHOT,
	)

	player.velocity = Vector2(100.0, GameConfig.MAX_FALL_SPEED)
	player.global_position = game.level.player_fallout.global_position + Vector2.DOWN * 5000
	await wait_physics_frames(3)

	assert_signal_emitted(player, "died", "Falling out should kill the player")
	assert_signal_not_emitted(player, "respawned", "Fallout respawn should be delayed")
	assert_true(player.is_dead, "Player should remain dead during the respawn delay")
	assert_false(player.visible, "Dead player should be hidden during the respawn delay")

	var did_respawn: bool = await wait_for_signal(
		player.respawned,
		0.5,
		"Waiting for fallout respawn delay",
	)
	assert_true(did_respawn, "Falling out should respawn the player after the delay")
	assert_true(
		player.global_position.x >= game.level.player_spawn_left.global_position.x
		and player.global_position.x <= game.level.player_spawn_right.global_position.x,
		"Player should respawn within the horizontal spawn range",
	)
	assert_almost_eq(
		player.global_position.y,
		game.level.player_spawn_left.global_position.y,
		5.0,
		"Player should respawn high above the platform",
	)
	assert_eq(velocity_at_respawn[0], Vector2.ZERO, "Respawning should clear fall velocity")
	assert_eq(player.jumps_remaining, 2, "Respawning should restore both jumps")
	assert_false(player.is_dead, "Player should be alive after respawning")
	assert_true(player.visible, "Player should be visible after respawning")


func test_repeated_death_requests_do_not_restart_respawn_delay() -> void:
	player.respawn_delay = 0.1
	var death_count := [0]
	player.died.connect(
		func() -> void:
			death_count[0] += 1,
	)

	player.die()
	await wait_seconds(0.05)
	player.die()
	var did_respawn: bool = await wait_for_signal(
		player.respawned,
		0.1,
		"Waiting for the original respawn delay",
	)

	assert_eq(death_count[0], 1, "A dead player should not die again")
	assert_true(did_respawn, "A repeated death should not restart the respawn delay")


func test_respawning_varies_the_horizontal_position() -> void:
	# player.respawn_rng.seed = 12345
	var horizontal_positions := { }

	for iteration in 8:
		player.respawn()
		horizontal_positions[player.global_position.x] = true

	assert_gt(
		horizontal_positions.size(),
		1,
		"Repeated respawns should not always choose the same horizontal position",
	)


func _press_jump() -> void:
	Input.action_press("jump")
	await wait_physics_frames(2)
	Input.action_release("jump")
	await wait_physics_frames(2)
