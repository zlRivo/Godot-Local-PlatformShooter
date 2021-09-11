extends Node

# Menu scene
# World scenes
var plain_ground_map_scene = preload("res://Scenes/Maps/PlainGroundMap/PlainGroundMap.tscn")
onready var map = $Map

func _ready():
	var plain_ground_map = plain_ground_map_scene.instance()
	map.add_child(plain_ground_map)
