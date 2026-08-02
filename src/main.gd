extends Node2D


func _ready() -> void:
	# get launch args
	var args := OS.get_cmdline_user_args()
	prints("Launch args: ", args)

	match Array(args):
		["host", var port]:
			#_start_host(int(port))
			prints("host", port)
		["join", var host, var port]:
			prints("join", host, port)
			#_start_client(host, int(port))
		[]:
			_start_menu()
		_:
			push_error("Invalid launch arguments: " + str(args))
			_start_menu()


func _start_menu() -> void:
	var multiplayer_menu := load("uid://b1carwajjk4ir")
	ScreenManager.switch(multiplayer_menu.instantiate())


func _start_host(port: int) -> void:
	var server: MultiplayerServer = load("res://src/multiplayer_server.tscn").instantiate()
	ScreenManager.switch(server)
	server.start(port)


func _start_client(host: String, port: int) -> void:
	var client: MultiplayerClient = load("res://src/multiplayer_client.tscn").instantiate()
	ScreenManager.switch(client)
	client.start(host, port)
