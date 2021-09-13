extends Camera2D

onready var default_zoom = zoom
onready var target_zoom = default_zoom

func get_camera_default_zoom():
	return default_zoom

func set_camera_zoom(new_zoom):
	target_zoom = new_zoom

func reset_camera_zoom():
	target_zoom = default_zoom

func _process(delta):
	# If we just set the camera zoom
	if target_zoom != zoom:
		# Update zoom
		zoom = lerp(zoom, target_zoom, 5 * delta)
