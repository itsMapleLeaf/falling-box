extends Node


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	match Array(args):
		['host', var port]:
			var game: ServerGame = Screens.server_game()
			ScreenManager.set_screen(game)
			game.host_server(str(port).to_int())

		['join', var host, var port]:
			var game: ServerGame = Screens.server_game()
			ScreenManager.set_screen(game)
			game.join_server(str(host), str(port).to_int())

		['play']:
			ScreenManager.set_screen(Screens.local_game())

		[]:
			ScreenManager.set_screen(Screens.main_menu())

		_:
			printerr("unknown arguments:", args)
			ScreenManager.set_screen(Screens.main_menu())
