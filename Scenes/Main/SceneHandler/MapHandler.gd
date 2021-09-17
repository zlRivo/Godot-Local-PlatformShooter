extends Node

# World scenes
var world_scenes = {
	"PlainGround": preload("res://Scenes/Maps/PlainGroundMap/PlainGroundMap.tscn"),
	"SnowyTown": preload("res://Scenes/Maps/SnowyTownMap/SnowyTownMap.tscn")
}

var map = null

func get_items_container():
	if map != null:
		return map.get_items_container()
	return null

func get_player_spawns():
	if map != null:
		return map.get_player_spawns()
	return null

# Return a random element from the spawn container
func get_random_spawn():
	if map != null:
		return map.get_random_spawn()
	return null

func set_map(_map : PackedScene):
	# If there is an existing map delete it
	if map != null:
		map.queue_free()
	
	# Create world
	var new_map = _map.instance()
	add_child(new_map)
	# Set reference
	map = new_map

func add_node(node_to_add : Node):
	if map != null:
		map.add_child(node_to_add)
		return true
	return false

# Returns a random map from the dictionary
func get_random_map() -> PackedScene:
	# Better random
	randomize()
	# Get keys of dictionary
	var world_keys = world_scenes.keys()
	# Return random map
	return world_scenes[world_keys[randi() % world_keys.size()]]

# Get current world preview camera reference
func get_preview_camera():
	if map == null:
		return null
		
	return map.get_preview_camera()

# Get current world game camera reference
func get_game_camera():
	if map == null:
		return null
		
	return map.get_game_camera()

# Get default zoom
func get_preview_camera_default_zoom():
	if map == null:
		return Vector2(-1, -1)
		
	return map.get_preview_camera_default_zoom()
