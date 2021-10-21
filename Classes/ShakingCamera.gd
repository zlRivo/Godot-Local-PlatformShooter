extends Camera2D
class_name ShakingCamera

var shake_timer = null
var shake_tween = null

func _ready():
	# Setup timer
	shake_timer = Timer.new()
	shake_timer.name = "ShakeTimer"
	shake_timer.one_shot = true
	shake_timer.autostart = false
	
	add_child(shake_timer)
	# Connect timeout signal
	shake_timer.connect("timeout", self, "_on_ShakeTimer_timeout")
	
	# Setup tween
	shake_tween = Tween.new()
	shake_tween.name = "ShakeTween"
	add_child(shake_tween)

# Used for camera shake
var shake_amount = 0
var shake_limit = 200
var default_offset = offset # Save default offset before shake
var shaking = false

func shake(new_shake_amount, shake_time = 0.4):
	# Increases the offset of the camera randomly
	shake_amount += new_shake_amount
	# Clamp shake amount
	if shake_amount > shake_limit:
		shake_amount = shake_limit
	
	# Set shake duration
	shake_timer.wait_time = shake_time
	
	# Stop current shake
	shake_tween.stop_all()
	
	# Start shaking
	shaking = true
	shake_timer.start()

func _on_ShakeTimer_timeout():
	# Disable shaking
	shake_amount = 0
	shaking = false
	
	# Start fading out animation
	shake_tween.interpolate_property(self, "offset", offset, default_offset,
	0.25, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	shake_tween.start()
