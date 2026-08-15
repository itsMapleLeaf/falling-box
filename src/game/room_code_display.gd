class_name RoomCodeDisplay
extends CanvasLayer

var current_room_code: String

@onready var room_code_label: Label = %RoomCodeLabel
@onready var room_code_connecting_display: Control = %RoomCodeConnectingDisplay
@onready var room_code_connected_display: Control = %RoomCodeConnectedDisplay
@onready var copied_label: Label = %CopiedText


func show_room_code(room_code: String) -> void:
	room_code_label.text = room_code
	room_code_connecting_display.hide()
	room_code_connected_display.show()
	current_room_code = room_code


func _on_room_code_copy_button_pressed() -> void:
	DisplayServer.clipboard_set(current_room_code)
	copied_label.text = "Copied!"
	await get_tree().create_timer(1.0).timeout
	copied_label.text = "Click to copy to clipboard"
