class_name LocalGame
extends Screen

const PLAYER = preload("uid://dgfxlv2n2qtvd")

@onready var game: Game = %Game


func _ready() -> void:
	var player := game.create_player()
	player.is_local = true
	game.add_child(player)
	game.falling_box_spawn_timer.timeout.connect(_on_falling_box_spawn_timer_timeout)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_quit"):
		var main_menu: MainMenu = load("uid://i4jvedvwx3en").instantiate()
		_change_screen(main_menu)


func play_offline() -> void:
	var player := game.create_player()
	player.is_local = true
	add_child(player)


func _on_falling_box_spawn_timer_timeout() -> void:
	game.add_child(game.create_falling_box(game.level.get_random_box_spawn_position()))
