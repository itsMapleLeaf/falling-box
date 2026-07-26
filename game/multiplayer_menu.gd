extends Screen

@onready var address_input: LineEdit = %AddressInput


func _on_host_button_pressed() -> void:
	var gameplay: Gameplay = load("uid://bhljs2y0to2fx").instantiate()
	ScreenManager.switch(gameplay)
	gameplay.start_server()


func _on_connect_button_pressed() -> void:
	var gameplay: Gameplay = load("uid://bhljs2y0to2fx").instantiate()
	ScreenManager.switch(gameplay)
	gameplay.start_client()
