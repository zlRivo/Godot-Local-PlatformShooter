extends ShakingCamera

# Player container reference
var player_container_node = null

var CAMERA_MARGIN = 128 # Number of pixels to expand the rectangle
var MIN_ZOOM = 0.2 # Minimum zoom, so if players are close, it wont zoom in too much

var players = null
var camera_rect = null

var handle_physics_process = false

func _ready():
	if Globals.get_in_editor_state():
		if not Globals.is_editor_tree_ready():
			# Wait for tree to initialize
			yield(get_tree().root, "ready")
	else:
		if not Globals.is_game_tree_ready():
			# Wait for tree to initialize
			yield(get_tree().root, "ready")
	
	# Get correct reference
	if Globals.get_in_editor_state():
		player_container_node = get_node("/root/LevelEditor/PlayerContainer")
	else:
		player_container_node = get_node("/root/SceneHandler/Players")
	
	refresh_player_container()

func refresh_player_container():
	# Stop moving the camera along the players
	set_physics_process(false)
	handle_physics_process = false
	
	if player_container_node != null:
		# Get players
		players = player_container_node.get_children()
		# Start updating the camera if there is at least one player
		# in the container
		if players != null and players.size() > 0:
			set_physics_process(true)
			handle_physics_process = true

func _physics_process(delta):
	#if players == null:
	#	return
	if handle_physics_process == false:
		return
	
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
