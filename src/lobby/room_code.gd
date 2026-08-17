class_name LobbyRoomCodeDisplay
extends PanelContainer

var room_code: String = ""

@onready var code_label: Label = %Code
@onready var copy_info_label: Label = %CopyTip
@onready var copy_info_text: String = copy_info_label.text
@onready var copy_button: TextureButton = %CopyButton


func set_room_code(new_room_code: String) -> void:
	room_code = new_room_code
	code_label.text = new_room_code


func _on_copy_button_pressed() -> void:
	DisplayServer.clipboard_set(room_code)
	copy_info_label.text = "Copied!"
	await get_tree().create_timer(1).timeout
	copy_info_label.text = copy_info_text
