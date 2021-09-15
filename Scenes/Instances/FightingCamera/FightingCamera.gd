extends Camera2D

# Player container reference
onready var player_container_node = get_node("/root/SceneHandler/Players")

# Other references
onready var shake_tween = $ShakeTween
onready var shake_timer = $ShakeTimer

# Used for camera shake
var shake_amount = 0
var shake_limit = 300
var default_offset = offset # Save default offset before shake
var shaking = false

var CAMERA_MARGIN = 64 # Number of pixels to expand the rectangle
var MIN_ZOOM = 0.2 # Minimum zoom, so if players are close, it wont zoom in too much

var players = null
var camera_rect = null

func _ready():
	refresh_player_container()

func refresh_player_container():
	set_process(false)
	
	if player_container_node != null:
		# Get players
		players = player_container_node.get_children()
		# Start updating the camera if there is at least one player
		# in the container
		if players.size() > 0:
			set_process(true)

func _process(delta):
	# Create rect to fit the first player
	camera_rect = Rect2(players[0].position, Vector2())
	# Expand to fit the other players
	for i in range(players.size()):
		if i == 0:
			# Skip first player since it already was added
			continue
		camera_rect = camera_rect.expand(players[i].position)
	
	# Grow rectangle
	camera_rect = camera_rect.grow(CAMERA_MARGIN)
	
	# Find the width and height scale, then choose the smallest one
	var window_size = OS.get_window_size()
	var scale_w = window_size.x / camera_rect.size.x
	var scale_h = window_size.y / camera_rect.size.y
	var scale = 1 / min(scale_w, scale_h)
	
	# Limit the zoom
	scale = max(MIN_ZOOM, scale)
	
	# Set zoom and position
	zoom = Vector2(scale, scale)
	position = camera_rect.position + (camera_rect.size * 0.5)
	
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
