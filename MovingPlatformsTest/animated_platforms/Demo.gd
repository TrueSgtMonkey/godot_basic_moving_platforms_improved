extends Spatial


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventKey:
		if event.pressed and event.as_text() == "Escape":
			get_tree().quit()
		elif event.pressed and event.as_text() == "F11":
			OS.window_fullscreen = !OS.window_fullscreen
