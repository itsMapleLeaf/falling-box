class_name MultiplayerServer
extends Screen

var peer := ENetMultiplayerPeer.new()

@onready var game: Game = %Game

var players_by_peer_id: Dictionary[int, Player] = { }


func start(port: int) -> void:
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func exit_screen() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


func _on_peer_connected(id: int) -> void:
	prints("connected:", id)

	var player: Player = game.add_player()
	players_by_peer_id[id] = player

	if not game.camera.target:
		game.camera.target = player


func _on_peer_disconnected(id: int) -> void:
	prints("disconnected:", id)

	var player := players_by_peer_id[id]
	if player:
		game.remove_player(player)
		players_by_peer_id.erase(id)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action("debug_exit"):
		_leave()


func _leave():
	var multiplayer_menu_scene := load("uid://b1carwajjk4ir")
	ScreenManager.switch(multiplayer_menu_scene.instantiate())
