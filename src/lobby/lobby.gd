extends Control

@onready var player_info: InstancePlaceholder = %PlayerInfo
@onready var room_code_ui: LobbyRoomCodeDisplay = %RoomCode


func _ready() -> void:
	room_code_ui.set_room_code("HIMOM")

	for i in 3:
		var inst: LobbyPlayerDisplay = player_info.create_instance()
		inst.set_player_name("Player %d" % i)
		inst.set_player_is_self(i == 0)
		inst.set_player_ready(i == 0)
