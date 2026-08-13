extends Node

const LOCAL_GAME = preload("uid://d2ms6aaidbi2r")
const ONLINE_GAME = preload("uid://b1qv6wynt2ae0")
const NETWORK_MENU = preload("uid://i4jvedvwx3en")

var screen: Screen


func _set_screen(new_screen: Screen) -> void:
	if screen:
		screen.exit_screen()
		screen.queue_free()

	screen = new_screen
	screen.screen_changed.connect(_set_screen)
	add_child(screen)


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	match Array(args):
		['host', var port]:
			var game: OnlineGame = ONLINE_GAME.instantiate()
			_set_screen(game)
			game.host_server(int(port))

		['join', var host, var port]:
			var game: OnlineGame = ONLINE_GAME.instantiate()
			_set_screen(game)
			game.join_server(host, int(port))

		['play']:
			_set_screen(LOCAL_GAME.instantiate())

		[]:
			_set_screen(NETWORK_MENU.instantiate())

		_:
			printerr("unknown arguments:", args)
			_set_screen(NETWORK_MENU.instantiate())
