class_name LobbyUI
extends Control

signal leave_requested
signal started

const PLAYER_STATUS = preload("uid://2n1e1fu55j36")

var players_by_peer_id: Dictionary[int, LobbyPlayerStatus] = { }

@onready var room_code_ui: LobbyRoomCodeDisplay = %RoomCode
@onready var player_list: Control = %PlayerList
@onready var leave_button: Button = %LeaveButton
@onready var start_info: Label = %StartInfo
@onready var start_button: Button = %StartButton


func _ready() -> void:
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func _on_peer_disconnected(peer_id: int) -> void:
	remove_player(peer_id)


func set_leave_button_text(text: String) -> void:
	leave_button.text = text


func add_player(peer_id: int, player_name: String) -> void:
	var player_status: LobbyPlayerStatus = PLAYER_STATUS.instantiate()
	player_status.peer_id = peer_id
	player_list.add_child(player_status, true)
	player_status.set_player_name(player_name)
	players_by_peer_id[peer_id] = player_status
	_update_start()


func remove_player(peer_id: int) -> void:
	var player: LobbyPlayerStatus = players_by_peer_id.get(peer_id)
	if not player:
		return

	players_by_peer_id.erase(peer_id)
	player.queue_free()
	_update_start()


func set_room_code(room_code: String) -> void:
	room_code_ui.set_room_code(room_code)


func _update_start() -> void:
	start_info.visible = multiplayer.is_server() and players_by_peer_id.size() < 2
	start_button.visible = multiplayer.is_server() and players_by_peer_id.size() >= 2


func _on_leave_button_pressed() -> void:
	leave_requested.emit()


func _on_start_button_pressed() -> void:
	started.emit()


func _on_player_status_spawner_spawned(node: LobbyPlayerStatus) -> void:
	players_by_peer_id[node.peer_id] = node
	_update_start()


func _on_player_status_spawner_despawned(node: LobbyPlayerStatus) -> void:
	players_by_peer_id.erase(node.peer_id)
	_update_start()
