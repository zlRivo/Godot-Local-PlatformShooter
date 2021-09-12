extends Node

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
	

func quit_match():
	pass
