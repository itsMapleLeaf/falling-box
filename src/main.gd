extends Node

const GAME = preload("uid://behcxl4o21rrt")
const NETWORK_MENU = preload("uid://i4jvedvwx3en")

var screen: Screen
var initial_title: String


func _set_screen(new_screen: Screen) -> void:
	if screen:
		screen.queue_free()

	get_window().title = initial_title

	screen = new_screen
	screen.screen_changed.connect(_set_screen)
	add_child(screen)


func _ready() -> void:
	initial_title = get_window().title

	var args := OS.get_cmdline_user_args()
	match Array(args):
		['host', var port]:
			var game: Game = GAME.instantiate()
			_set_screen(game)
			game.host_server(int(port))

		['join', var host, var port]:
			var game: Game = GAME.instantiate()
			_set_screen(game)
			game.join_server(host, int(port))

		['play']:
			var game: Game = GAME.instantiate()
			_set_screen(game)
			game.play_offline()

		[]:
			_set_screen(NETWORK_MENU.instantiate())

		_:
			printerr("unknown arguments:", args)
			_set_screen(NETWORK_MENU.instantiate())
