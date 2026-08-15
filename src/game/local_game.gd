extends Screen

@onready var game: Game = %Game


func _ready() -> void:
	get_window().title = "falling box [offline]"

	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

	game.falling_box_spawn_timer.timeout.connect(game._on_falling_box_spawn_timer_timeout)

	var data := PlayerSpawner.PlayerSpawnData.new(1)
	data.alias = "You"
	game.player_spawner.spawn(inst_to_dict(data))
