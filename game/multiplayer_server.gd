extends Screen

var peer := ENetMultiplayerPeer.new()

@onready var game: Game = %Game
var player: Player


func _ready() -> void:
	peer.create_server(7586)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	player = game.spawn_player()


func exit_screen() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


func _on_peer_connected(id: int) -> void:
	prints("connected:", id)


func _on_peer_disconnected(id: int) -> void:
	prints("disconnected:", id)


func _on_stop_button_pressed() -> void:
	_leave()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action("debug_exit"):
		_leave()


func _leave():
	var multiplayer_menu_scene := load("uid://b1carwajjk4ir")
	ScreenManager.switch(multiplayer_menu_scene.instantiate())
