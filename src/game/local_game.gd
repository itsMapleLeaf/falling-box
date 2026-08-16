extends Screen

@onready var game: Game = %Game


func _ready() -> void:
	get_window().title = "falling box [offline]"

	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

	game.spawn_falling_blocks()

	var data := PlayerSpawner.PlayerSpawnData.new()
	data.alias = "You"
	game.add_player(data)
