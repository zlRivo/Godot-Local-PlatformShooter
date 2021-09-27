extends Node

# References
onready var map_handler = $MapHandler
onready var player_hud_container = $CanvasPlayerHUD/ContainerPlayerHUD

func _ready():
	Globals.set_in_editor_state(false)
	# Enable physics
	Physics2DServer.set_active(true)
	# Hide cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	# Set to full screen
	OS.set_window_fullscreen(true)
	# Set a random map on start
	map_handler.set_map(map_handler.get_random_map())
