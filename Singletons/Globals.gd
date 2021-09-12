extends Node

var active_camera = null

func set_camera(new_cam : Camera2D):
	new_cam.current = true
	active_camera = new_cam

func shake_camera(new_shake_amount, shake_time = 0.4, shake_limit = 300):
	if active_camera == null:
		return
		
	if active_camera.has_method("shake"):
		active_camera.shake(new_shake_amount, shake_time)
