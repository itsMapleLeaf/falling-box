extends GutTest

var _sender := GutInputSender.new()


func after_each():
	_sender.release_all()
	_sender.clear()


func test_play_starts_local_game():
	var menu := Screens.main_menu()
	add_child_autofree(menu)

	var play_button: Button = menu.get_node("%PlayButton")
	play_button.emit_signal("pressed")

	assert_not_null(
		ScreenManager.current_screen,
		"The current screen should be set after pressing Play",
	)
	assert_eq(
		ScreenManager.current_screen.get_class(),
		Screens.local_game().get_class(),
		"Pressing Play should open the local game screen",
	)
