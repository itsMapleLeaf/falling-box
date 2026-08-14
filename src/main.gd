extends Node

const GAME = preload("uid://behcxl4o21rrt")
const NETWORK_MENU = preload("uid://i4jvedvwx3en")


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	match Array(args):
		['host', var port]:
			var game: Game = GAME.instantiate()
			ScreenManager.set_screen(game)
			game.host_server(int(port))

		['join', var host, var port]:
			var game: Game = GAME.instantiate()
			ScreenManager.set_screen(game)
			game.join_server(host, int(port))

		['play']:
			var game: Game = GAME.instantiate()
			ScreenManager.set_screen(game)
			game.play_offline()

		[]:
			ScreenManager.set_screen(NETWORK_MENU.instantiate())

		_:
			printerr("unknown arguments:", args)
			ScreenManager.set_screen(NETWORK_MENU.instantiate())
