extends Node

onready var player_container = get_node("/root/SceneHandler/Players")

func vanish_players():
	for p in get_children():
		if p.has_method("vanish"):
			p.vanish()
		else:
			# Delete it anyway
			player_container.remove_child(p)
			# Refresh players in containers
			Globals.refresh_player_container()
