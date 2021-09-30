extends Node

onready var map = $Map

# Emitted when a map gets loaded
signal map_changed

func _ready():
	# Wait until the tree is fully loaded
	yield(get_tree().root, "ready")
	# To initialize the map references
	emit_signal("map_changed")

# Return the current map as a scene
func pack_map():
	if map == null:
		return null
	
	return ScenePacker.pack_node(map)

func get_tilemap():
	if map != null:
		return map.get_tilemap()
	return null

func get_projectile_container():
	if map != null:
		return map.get_projectile_container()
	return null

func get_decal_container():
	if map != null:
		return map.get_decal_container()
	return null

func get_items_container():
	if map != null:
		return map.get_items_container()
	return null

func get_terrain_items_container():
	if map != null:
		return map.get_terrain_items_container()
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

func add_node(node_to_add : Node):
	if map != null:
		map.add_child(node_to_add)
		return true
	return false

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

func set_map(_new_map : PackedScene):
	# If there is an existing map delete it
	if map != null:
		map.queue_free()
	
	# Create world
	var _new_map_inst = _new_map.instance()
	add_child(_new_map_inst)
	# Set reference
	map = _new_map_inst
	emit_signal("map_changed")

func get_map():
	return map
