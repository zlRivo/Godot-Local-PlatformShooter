extends Control

onready var player_selector_container = $ContainerPlayerSelector

func set_all_players_active_state(new_state):
	player_selector_container.set_all_players_active_state(new_state)
