class_name LobbyUI
extends Control

signal leave_requested

const PLAYER_STATUS = preload("uid://2n1e1fu55j36")

var players_by_peer_id: Dictionary[int, LobbyPlayerStatus] = { }

@onready var room_code_ui: LobbyRoomCodeDisplay = %RoomCode
@onready var player_list: Control = %PlayerList
@onready var leave_button: Button = %LeaveButton


func set_leave_button_text(text: String) -> void:
	leave_button.text = text


func add_player(peer_id: int, player_name: String, is_self: bool) -> void:
	var player_status: LobbyPlayerStatus = PLAYER_STATUS.instantiate()
	player_list.add_child(player_status, true)
	player_status.set_player_name(player_name)
	player_status.set_player_is_self(is_self)
	players_by_peer_id[peer_id] = player_status


func remove_player(peer_id: int) -> void:
	var player: LobbyPlayerStatus = players_by_peer_id.get(peer_id)
	if not player:
		return

	players_by_peer_id.erase(peer_id)
	player.queue_free()


func set_room_code(room_code: String) -> void:
	room_code_ui.set_room_code(room_code)


func _on_leave_button_pressed() -> void:
	leave_requested.emit()
