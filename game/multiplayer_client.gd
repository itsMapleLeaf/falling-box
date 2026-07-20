extends Screen

var peer := ENetMultiplayerPeer.new()


func _ready() -> void:
	peer.create_client("localhost", 7586)
	multiplayer.multiplayer_peer = peer


func exit_screen() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


func _leave():
	var multiplayer_menu_scene := load("uid://b1carwajjk4ir")
	ScreenManager.switch(multiplayer_menu_scene.instantiate())


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action("debug_exit"):
		_leave()
