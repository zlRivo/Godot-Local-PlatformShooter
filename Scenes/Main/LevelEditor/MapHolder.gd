extends Node

onready var map = $Map

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

func get_player_spawns():
	if map != null:
		return map.get_player_spawns()
	return null

# Return a random element from the spawn container
func get_random_spawn():
	if map != null:
		return map.get_random_spawn()
	return null

func set_map(_new_map : PackedScene):
	map = _new_map
