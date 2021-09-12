extends Node

# Menu scene
# World scenes
var world_scenes = {
	"PlainGround": preload("res://Scenes/Maps/PlainGroundMap/PlainGroundMap.tscn"),
	"SnowyTown": preload("res://Scenes/Maps/SnowyTownMap/SnowyTownMap.tscn")
}

onready var map = $Map

func _ready():
	# Set a random map on start
	map.set_map(get_random_map())
	
# Returns a random map from the dictionary
func get_random_map() -> PackedScene:
	# Better random
	randomize()
	# Get keys of dictionary
	var world_keys = world_scenes.keys()
	# Return random map
	return world_scenes[world_keys[randi() % world_keys.size()]]
