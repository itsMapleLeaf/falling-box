class_name Game
extends Screen

var peer := ENetMultiplayerPeer.new()


func _ready() -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_quit"):
		_change_screen(load("uid://i4jvedvwx3en").instantiate())


func host_server(port: int) -> void:
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer


func join_server(host: String, port: int) -> void:
	peer.create_client(host, port)
	multiplayer.multiplayer_peer = peer
