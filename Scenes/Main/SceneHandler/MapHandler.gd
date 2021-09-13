extends Node

# World scenes
var world_scenes = {
	"PlainGround": preload("res://Scenes/Maps/PlainGroundMap/PlainGroundMap.tscn"),
	"SnowyTown": preload("res://Scenes/Maps/SnowyTownMap/SnowyTownMap.tscn")
}

var map = null

func set_map(_map : PackedScene):
	# If there is an existing map delete it
	if map != null:
		map.queue_free()
	
	# Create world
	var new_map = _map.instance()
	add_child(new_map)
	# Set reference
	map = new_map
	
# Returns a random map from the dictionary
func get_random_map() -> PackedScene:
	# Better random
	randomize()
	# Get keys of dictionary
	var world_keys = world_scenes.keys()
	# Return random map
	return world_scenes[world_keys[randi() % world_keys.size()]]

func quit_match():
	pass
