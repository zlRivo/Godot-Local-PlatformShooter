extends Node2D
class_name Map

export (NodePath) var game_camera_path
onready var game_camera = get_node_or_null(game_camera_path)

export (NodePath) var preview_camera_path
onready var preview_camera = get_node_or_null(preview_camera_path)

func set_to_preview_camera():
	if preview_camera != null:
		Globals.set_camera(preview_camera)
		
func set_to_game_camera():
	if game_camera != null:
		Globals.set_camera(game_camera)

func get_preview_camera():
	return preview_camera

func get_game_camera():
	return game_camera

func get_preview_camera_default_zoom():
	if preview_camera == null:
		return Vector2(-1, -1)
	
	return preview_camera.get_camera_default_zoom()
