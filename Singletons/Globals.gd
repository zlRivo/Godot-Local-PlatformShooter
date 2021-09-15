extends Node

var active_camera = null
var default_camera_zoom = 1
onready var target_camera_zoom = default_camera_zoom

# Know if the player is in game
var in_game = false

func refresh_player_container():
	if active_camera.has_method("refresh_player_container"):
		active_camera.refresh_player_container()

func set_camera_process(new_state):
	if active_camera != null:
		active_camera.set_process(new_state)

func set_camera(new_cam : Camera2D):
	new_cam.current = true
	active_camera = new_cam
	default_camera_zoom = new_cam.zoom

func shake_camera(new_shake_amount, shake_time = 0.4):
	if active_camera == null:
		return
		
	if active_camera.has_method("shake"):
		active_camera.shake(new_shake_amount, shake_time)

# Know if the player is in game
func is_in_game():
	return in_game

func set_in_game_state(new_state):
	in_game = new_state
