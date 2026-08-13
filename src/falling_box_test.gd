extends GutTest

const GAME := preload("res://src/game.tscn")
const FALLING_BOX := preload("res://src/falling_box.tscn")

var game: Game
var player: Player


func before_each() -> void:
	game = add_child_autofree(GAME.instantiate())
	player = game.create_player()
	game.add_child(player)


func after_each() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")


func _add_box(at_position: Vector2) -> FallingBox:
	var box: FallingBox = FALLING_BOX.instantiate()
	box.landed_lifetime_seconds = 100.0
	game.add_child(box)
	box.global_position = at_position
	return box


func test_box_fades_in_while_falling() -> void:
	var box := _add_box(Vector2(0.0, -300.0))
	assert_almost_eq(box.visual.modulate.a, 0.0, 0.001, "Box should begin transparent")

	await wait_seconds(box.spawn_fade_seconds * 0.5)
	assert_gt(box.visual.modulate.a, 0.0, "Box should become visible during spawn fade")
	assert_lt(box.visual.modulate.a, 1.0, "Box should not become opaque halfway through its fade")

	await wait_seconds(box.spawn_fade_seconds)
	assert_almost_eq(box.visual.modulate.a, 1.0, 0.001, "Box should finish opaque")


func test_box_stops_and_snaps_to_grid_when_it_lands() -> void:
	var box := _add_box(Vector2(0.0, -200.0))
	var did_land: bool = await wait_for_signal(box.grounded, 2.0, "Waiting for box to land")
	assert_true(did_land, "Box should land before the timeout")
	if not did_land:
		return

	assert_eq(box.state, FallingBox.State.GROUNDED, "Box should stop after landing")
	assert_eq(box.velocity, Vector2.ZERO, "Grounded box should have no velocity")
	assert_eq(box.global_position, Vector2(0.0, -50.0), "Box should land on the grid")


func test_boxes_stack_on_the_grid() -> void:
	var lower_box := _add_box(Vector2(0.0, -200.0))
	var lower_did_land: bool = await wait_for_signal(
		lower_box.grounded,
		2.0,
		"Waiting for lower box",
	)
	assert_true(lower_did_land, "Lower box should land before the timeout")
	if not lower_did_land:
		return

	var upper_box := _add_box(Vector2(0.0, -200.0))
	var upper_did_land: bool = await wait_for_signal(
		upper_box.grounded,
		2.0,
		"Waiting for upper box",
	)
	assert_true(upper_did_land, "Upper box should land before the timeout")
	if not upper_did_land:
		return

	assert_eq(lower_box.global_position, Vector2(0.0, -50.0), "Lower box should stay put")
	assert_eq(upper_box.state, FallingBox.State.GROUNDED, "Upper box should land")
	assert_eq(upper_box.global_position, Vector2(0.0, -100.0), "Boxes should stack by one cell")


func test_player_is_blocked_by_a_grounded_box() -> void:
	var box := _add_box(Vector2(0.0, -50.0))
	var did_land: bool = await wait_for_signal(box.grounded, 1.0, "Waiting for blocking box")
	assert_true(did_land, "Blocking box should become grounded")
	if not did_land:
		return

	player.global_position = Vector2(-100.0, -45.0)
	player.velocity = Vector2.ZERO
	player.reset_physics_interpolation()
	await wait_physics_frames(2)
	watch_signals(player)

	Input.action_press("move_right")
	await wait_physics_frames(30)
	Input.action_release("move_right")

	assert_lt(player.global_position.x, -43.0, "Player should not pass through the box")
	assert_eq(box.global_position, Vector2(0.0, -50.0), "Player should not move the box")
	assert_signal_not_emitted(player, "died", "A grounded box should not squish the player")


func test_falling_box_passes_through_player_without_reacting() -> void:
	player.set_physics_process(false)
	player.global_position = Vector2(0.0, -150.0)
	player.velocity = Vector2.ZERO
	player.reset_physics_interpolation()

	var box := _add_box(Vector2(0.0, -250.0))
	var did_pass_player: bool = await wait_until(
		func() -> bool:
			return box.global_position.y > player.global_position.y + 50.0,
		2.0,
		"Waiting for box to pass through player",
	)

	assert_true(did_pass_player, "Falling box should pass completely through the player")
	assert_eq(box.state, FallingBox.State.FALLING, "Player should not ground a falling box")


func test_falling_box_squishes_player_against_floor() -> void:
	player.respawn_delay = 0.1
	player.global_position = Vector2(0.0, -45.0)
	player.velocity = Vector2.ZERO
	player.reset_physics_interpolation()
	await wait_physics_frames(3)
	assert_true(player.is_on_floor(), "Player should be standing on the platform")

	watch_signals(player)
	_add_box(Vector2(0.0, -150.0))
	var did_die: bool = await wait_for_signal(
		player.died,
		1.0,
		"Waiting for a falling box to squish the player",
	)

	assert_true(did_die, "A falling box should kill a player pinned against a floor")
	assert_signal_not_emitted(player, "respawned", "Squish respawn should be delayed")
	assert_true(player.is_dead, "A squished player should remain dead during the delay")
	var did_respawn: bool = await wait_for_signal(
		player.respawned,
		0.5,
		"Waiting for squish respawn delay",
	)
	assert_true(did_respawn, "A squished player should respawn after the delay")
	assert_eq(player.velocity, Vector2.ZERO, "Respawning should clear the player's velocity")


func test_falling_box_does_not_squish_airborne_player() -> void:
	player.global_position = Vector2(0.0, -300.0)
	player.velocity = Vector2.ZERO
	player.reset_physics_interpolation()
	await wait_physics_frames(1)
	assert_false(player.is_on_floor(), "Player should be airborne")

	watch_signals(player)
	_add_box(Vector2(0.0, -330.0))
	await wait_physics_frames(5)

	assert_signal_not_emitted(
		player,
		"died",
		"Contact with a falling box should only squish a player pinned against a floor",
	)


func test_expired_box_disables_collision_fades_falls_and_is_freed() -> void:
	var box := FALLING_BOX.instantiate() as FallingBox
	box.spawn_fade_seconds = 0.01
	box.landed_lifetime_seconds = 0.2
	box.despawn_fade_seconds = 0.25
	game.add_child(box)
	box.global_position = Vector2(0.0, -100.0)

	var did_land: bool = await wait_for_signal(
		box.grounded,
		2.0,
		"Waiting for expiring box to land",
	)
	assert_true(did_land, "Expiring box should land before the timeout")
	if not did_land:
		return

	assert_eq(box.state, FallingBox.State.GROUNDED, "Box should first become grounded")
	var grounded_y := box.global_position.y

	var did_expire: bool = await wait_for_signal(box.expiring, 1.0, "Waiting for box lifetime")
	assert_true(did_expire, "Grounded lifetime should expire before the timeout")
	if not did_expire:
		return
	await wait_physics_frames(2)

	assert_eq(box.state, FallingBox.State.EXPIRING, "Lifetime should begin expiration")
	assert_eq(box.collision_layer, 0, "Expiring box should leave collision layers")
	assert_eq(box.collision_mask, 0, "Expiring box should stop collision checks")
	assert_true(box.hitbox.disabled, "Expiring box hitbox should be disabled")
	assert_lt(box.visual.modulate.a, 1.0, "Expiring box should fade")
	assert_gt(box.global_position.y, grounded_y, "Expiring box should resume falling")

	var box_reference: WeakRef = weakref(box)
	var did_exit: bool = await wait_for_signal(box.tree_exited, 1.0, "Waiting for fade-out cleanup")
	assert_true(did_exit, "Fully transparent box should leave the scene before the timeout")
	await wait_process_frames(1)
	assert_null(box_reference.get_ref(), "Fully transparent box should be freed")
