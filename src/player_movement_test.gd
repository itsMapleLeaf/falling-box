extends SceneTree


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	root.add_child(main)

	for frame in 5:
		await physics_frame

	var player: CharacterBody2D = main.get_node("Player")
	var starting_x := player.position.x

	Input.action_press("move_right")
	for frame in 12:
		await physics_frame
	Input.action_release("move_right")

	if player.position.x <= starting_x:
		_fail("Player did not move right")
		return

	Input.action_press("jump")
	await physics_frame
	await physics_frame
	Input.action_release("jump")
	if player.velocity.y >= 0.0:
		_fail("First jump did not launch the player upward")
		return

	for frame in 5:
		await physics_frame

	Input.action_press("jump")
	await physics_frame
	await physics_frame
	Input.action_release("jump")
	if player.velocity.y >= 0.0 or player.jumps_remaining != 0:
		_fail("Second jump was not consumed correctly")
		return

	print("Player movement test passed")
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
