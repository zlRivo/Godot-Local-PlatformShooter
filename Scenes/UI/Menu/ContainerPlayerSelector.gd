extends HBoxContainer

# References
export (NodePath) var countdown_path
onready var countdown = get_node(countdown_path)

# Character selection choices
var character_selection_choices = {
	"doux" : preload("res://Assets/Sprites/Player/doux.png"),
	"mort" : preload("res://Assets/Sprites/Player/mort.png"),
	"tard" : preload("res://Assets/Sprites/Player/tard.png"),
	"vita" : preload("res://Assets/Sprites/Player/vita.png")
}

# Player ready states
var player1_ready_state = false
var player2_ready_state = false

func set_all_players_ready_state(new_ready_state : bool):
	for p in get_children():
		p.set_ready_state(new_ready_state)

func get_player_selection_index(owner_id) -> int:
	# Look for owner id
	for p in get_children():
		if p.get_owner_id() == owner_id:
			return p.get_selection_index()
	# Return -1 as not found
	return -1

# When a player change his selection
func _on_selection_changed(owner_id):
	pass
	
# When a player change his ready state
func _on_ready_state_changed(owner_id : int, new_state : bool):
	# Assign new ready states
	match owner_id:
		0:
			player1_ready_state = new_state
		1:
			player2_ready_state = new_state

	if player1_ready_state == true and player2_ready_state == true:
		# Start countdown
		if countdown != null:
			countdown.start_countdown(3)
		
	# If not all players are ready, stop countdown if it is active
	else:
		if countdown != null:
			if countdown.is_active():
				countdown.stop_countdown()

