extends Node2D
class_name Map

export (NodePath) var game_camera_path
onready var game_camera = get_node(game_camera_path)

export (NodePath) var preview_camera_path
onready var preview_camera = get_node(preview_camera_path)

func set_to_preview_camera():
	if preview_camera != null:
		Globals.set_camera(preview_camera)
		
func set_to_game_camera():
	if game_camera != null:
		Globals.set_camera(game_camera)
