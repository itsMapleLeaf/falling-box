class_name LobbyPlayerStatus
extends HBoxContainer

@export var peer_id: int = 0

@onready var name_label: Label = %Name
@onready var self_label: Label = %SelfLabel


func _ready() -> void:
	set_player_is_self(peer_id == multiplayer.get_unique_id())


func set_player_name(player_name: String) -> void:
	name_label.text = player_name


func set_player_is_self(is_self: bool) -> void:
	self_label.visible = is_self
