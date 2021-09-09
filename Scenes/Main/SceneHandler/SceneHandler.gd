extends Node

# Menu scene
# World scenes
var plain_ground_map_scene = preload("res://Scenes/Main/PlainGroundMap/PlainGroundMap.tscn")

func _ready():
	var plain_ground_map = plain_ground_map_scene.instance()
	add_child(plain_ground_map)
