extends Node2D


func _ready() -> void:
	var multiplayer_menu := load("uid://b1carwajjk4ir")
	ScreenManager.switch(multiplayer_menu.instantiate())
