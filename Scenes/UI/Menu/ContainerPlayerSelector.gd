extends HBoxContainer

# References
export (NodePath) var countdown_path
onready var countdown = get_node(countdown_path)

onready var map_handler = get_node("/root/SceneHandler/MapHandler")
onready var menu = get_node("/root/SceneHandler/Menu")
onready var players_container = get_node("/root/SceneHandler/Players")

# Character selection choices
var character_selection_choices = {
	"doux" : preload("res://Assets/Sprites/Player/doux.png"),
	"mort" : preload("res://Assets/Sprites/Player/mort.png"),
	"tard" : preload("res://Assets/Sprites/Player/tard.png"),
	"vita" : preload("res://Assets/Sprites/Player/vita.png")
}

# Player scene
var player_scene = preload("res://Scenes/Instances/Player/Player.tscn")

# Player ready states
var player1_ready_state = false
var player2_ready_state = false
var player1_selection_index = -1
var player2_selection_index = -1

func _ready():
	if countdown != null:
		countdown.connect("countdown_finished", self, "_on_countdown_finished")

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

# When the countdown finishes
func _on_countdown_finished():
	# Start game
	start_game()

func start_game():
	# Get selection of players
	for p in get_children():
		# Get ID of iterated player
		var player_owner_id = p.get_owner_id()
		
		# Switch for knowing player HUD reference
		var player_hud = null
		match player_owner_id:
			0:
				player_hud = get_node("/root/SceneHandler/CanvasPlayerHUD/ContainerPlayerHUD/Player1HUD")
			1:
				player_hud = get_node("/root/SceneHandler/CanvasPlayerHUD/ContainerPlayerHUD/Player1HUD")
		
		var new_player = player_scene.instance()
		# Add player to scene
		players_container.add_child(new_player)
		# Get maps' player spawns
		var player_spawns = map_handler
		
		var init_result = new_player.init_player(player_owner_id, p.get_selection_index(), player_spawns, player_hud)
		
		# If the player has had an error while initializing
		if init_result == false:
			# remove the player from the scene
			players_container.remove_child(new_player)
	
	# Reset players' ready states
	set_all_players_ready_state(false)
	# Start game on main menu
	menu.start_game()
