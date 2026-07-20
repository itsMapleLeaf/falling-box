extends Screen

@onready var address_input: LineEdit = %AddressInput


func _on_host_button_pressed() -> void:
	var multiplayer_server_scene := load("uid://e26iex8f85mj")
	ScreenManager.switch(multiplayer_server_scene.instantiate())


func _on_connect_button_pressed() -> void:
	var multiplayer_client_scene := load("uid://l5cq1fqrpluh")
	ScreenManager.switch(multiplayer_client_scene.instantiate())
