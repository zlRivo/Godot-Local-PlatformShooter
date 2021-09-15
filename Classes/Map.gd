extends Node2D
class_name Map

export (NodePath) var game_camera_path
onready var game_camera = get_node_or_null(game_camera_path)

export (NodePath) var preview_camera_path
onready var preview_camera = get_node_or_null(preview_camera_path)

# Player spawns reference
export (NodePath) var player_spawns_path
onready var player_spawns = get_node_or_null(player_spawns_path)

func get_player_spawns():
	if player_spawns != null:
		return player_spawns
	return null

# Return a random element from the spawn container
func get_random_spawn():
	# Get spawn count
	if player_spawns == null:
		return null
	# Get spawn count
	var spawn_count = player_spawns.get_child_count()
	if spawn_count == 0:
		return null	
	
	randomize()
	# Get random spawn from 0 to spawn count
	var rand_spawn_index = randi() % spawn_count
	# Return the spawn
	var random_spawn_pos = player_spawns.get_child(rand_spawn_index).position
	return random_spawn_pos

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
