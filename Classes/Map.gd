extends Node2D
class_name Map

"""
export (NodePath) var terrain_items_path
onready var terrain_items = get_node(terrain_items_path)
"""

export (NodePath) var camera_path
onready var camera = get_node(camera_path)

func set_to_active_camera():
	if camera != null:
		Globals.set_camera(camera)
