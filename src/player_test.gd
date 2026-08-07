extends GutTest

const MainScene := preload("res://src/main.tscn")

var main: Node2D
var player: Player


func before_each() -> void:
	main = add_child_autofree(MainScene.instantiate())
	player = main.get_node("Player")
	await wait_physics_frames(5)


func after_each() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")


func test_player_moves_right_and_faces_right() -> void:
	var starting_x := player.position.x

	Input.action_press("move_right")
	await wait_physics_frames(12)
	Input.action_release("move_right")

	assert_gt(player.position.x, starting_x, "Player should move to the right")
	assert_eq(player.facing, 1, "Player should face right while moving right")
	assert_gt(player.cursor.position.x, 0.0, "Cursor should appear on the right")


func test_player_moves_left_and_faces_left() -> void:
	var starting_x := player.position.x

	Input.action_press("move_left")
	await wait_physics_frames(12)
	Input.action_release("move_left")

	assert_lt(player.position.x, starting_x, "Player should move to the left")
	assert_eq(player.facing, -1, "Player should face left while moving left")
	assert_lt(player.cursor.position.x, 0.0, "Cursor should appear on the left")


func test_player_keeps_facing_right_after_movement_stops() -> void:
	Input.action_press("move_right")
	await wait_physics_frames(12)
	Input.action_release("move_right")
	await wait_physics_frames(2)

	assert_eq(player.facing, 1, "Neutral input should preserve the last facing direction")
	assert_gt(player.cursor.position.x, 0.0, "Cursor should remain on the facing side")


func test_player_can_double_jump_but_not_triple_jump() -> void:
	assert_true(player.is_on_floor(), "Player should begin on the platform")

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
		"A third jump should not reset upward velocity"
	)


func test_landing_restores_both_jumps() -> void:
	await _press_jump()
	await wait_physics_frames(5)
	await _press_jump()

	await wait_physics_frames(120)

	assert_true(player.is_on_floor(), "Player should land back on the platform")
	assert_eq(player.jumps_remaining, 2, "Landing should restore both jumps")


func _press_jump() -> void:
	Input.action_press("jump")
	await wait_physics_frames(2)
	Input.action_release("jump")
	await wait_physics_frames(2)
