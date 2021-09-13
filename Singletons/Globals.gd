extends Node

var active_camera = null
var default_camera_zoom = 1
onready var target_camera_zoom = default_camera_zoom

func set_camera(new_cam : Camera2D):
	new_cam.current = true
	active_camera = new_cam
	default_camera_zoom = new_cam.zoom

func shake_camera(new_shake_amount, shake_time = 0.4):
	if active_camera == null:
		return
		
	if active_camera.has_method("shake"):
		active_camera.shake(new_shake_amount, shake_time)

