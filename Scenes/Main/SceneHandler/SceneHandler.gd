extends Node

# References
onready var map_handler = $MapHandler
onready var player_hud_container = $CanvasPlayerHUD/ContainerPlayerHUD

func _ready():
	# Hide cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	# Set a random map on start
	map_handler.set_map(map_handler.get_random_map())
