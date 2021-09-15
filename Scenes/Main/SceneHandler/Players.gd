extends Node

func vanish_players():
	for p in get_children():
		if p.has_method("vanish"):
			p.vanish()
		else:
			# Prevent error
			Globals.set_camera_process(false)
			# Delete it anyway
			p.queue_free()
			# Refresh players in containers
			Globals.refresh_player_container()
