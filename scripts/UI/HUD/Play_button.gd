extends Button

func _pressed():
	self.get_parent().get_parent().hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("Play button pressed")
