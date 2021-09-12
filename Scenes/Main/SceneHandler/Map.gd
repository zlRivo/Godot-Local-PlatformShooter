extends Node

var game_world = null

func set_map(map : PackedScene):
	# If there is an existing world delete it
	if game_world != null:
		game_world.queue_free()
	
	# Create world
	var new_world = map.instance()
	add_child(new_world)
	# Set reference
	game_world = new_world
	

func quit_match():
	pass
