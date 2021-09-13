extends HBoxContainer

func set_all_players_ready_state(new_ready_state : bool):
	for p in get_children():
		p.set_ready_state(new_ready_state)
