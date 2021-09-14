extends Camera2D

onready var default_zoom = zoom
onready var target_zoom = default_zoom

# Other references
onready var shake_tween = $ShakeTween
onready var shake_timer = $ShakeTimer

# Used for camera shake
var shake_amount = 0
var shake_limit = 300
var default_offset = offset # Save default offset before shake
var shaking = false

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
		
	# Camera shake
	if shaking:
		offset = Vector2(rand_range(-shake_amount, shake_amount), rand_range(-shake_amount, shake_amount)) * delta + default_offset
		
func shake(new_shake_amount, shake_time = 0.4):
	shake_amount += new_shake_amount
	if shake_amount > shake_limit:
		shake_amount = shake_limit
	
	shake_timer.wait_time = shake_time
	
	shake_tween.stop_all()
	shaking = true
	shake_timer.start()


func _on_ShakeTimer_timeout():
	shake_amount = 0
	shaking = false
	
	shake_tween.interpolate_property(self, "offset", offset, default_offset,
	0.25, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	shake_tween.start()
