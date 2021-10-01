extends CanvasLayer

onready var map_handler = get_node("/root/SceneHandler/MapHandler")
onready var player_container = get_node("/root/SceneHandler/Players")

# References
onready var main_title = $MainMenuNode/MainTitle
onready var main_title_animation_player = $MainMenuNode/MainTitle/AnimationPlayer
onready var character_selection = $CharacterSelection
onready var main_menu_node = $MainMenuNode
onready var options_container = $MainMenuNode/OptionsContainer
onready var selector = $MainMenuNode/Selector
onready var main_menu_selection_description = $MainMenuNode/LabelDescription
onready var how_to_play_menu = $HowToPlayMenu
onready var credits_menu = $CreditsMenu
onready var credits_label_anim_player = $CreditsMenu/CreditsLabel/AnimationPlayer
onready var players_hud = get_node("/root/SceneHandler/CanvasPlayerHUD/ContainerPlayerHUD")

onready var player1_hud = get_node("/root/SceneHandler/CanvasPlayerHUD/ContainerPlayerHUD/Player1HUD")
onready var player2_hud = get_node("/root/SceneHandler/CanvasPlayerHUD/ContainerPlayerHUD/Player2HUD")
onready var player3_hud = get_node("/root/SceneHandler/CanvasPlayerHUD/ContainerPlayerHUD/Player3HUD")
onready var player4_hud = get_node("/root/SceneHandler/CanvasPlayerHUD/ContainerPlayerHUD/Player4HUD")

onready var player_hud_list = [
	get_node("/root/SceneHandler/CanvasPlayerHUD/ContainerPlayerHUD/Player1HUD"),
	get_node("/root/SceneHandler/CanvasPlayerHUD/ContainerPlayerHUD/Player2HUD"),
	get_node("/root/SceneHandler/CanvasPlayerHUD/ContainerPlayerHUD/Player3HUD"),
	get_node("/root/SceneHandler/CanvasPlayerHUD/ContainerPlayerHUD/Player4HUD")
]

# UI Action sound
onready var ui_action_sound = $UIActionSound
# Confirm sound
onready var ui_confirm_sound = $UIConfirmSound

# Current menu reference
onready var current_menu = main_menu_node

export (Vector2) var selector_offset = Vector2(-40, 0)
onready var menu_options_count = options_container.get_child_count()
var current_selection = -1
var target_label = null

func _input(event):
	# If we are not in game
	if not Globals.is_in_game():
		# Main menu
		if current_menu == main_menu_node:
			if event.is_action_pressed("ui_down"):
				set_current_selection(current_selection + 1)
			if event.is_action_pressed("ui_up"):
				set_current_selection(current_selection - 1)
			if event.is_action_pressed("ui_accept"):
				# Get node name from current selection reference
				var selected_node_name = target_label.name
				
				# Play UI Confirm sound
				ui_confirm_sound.play()
				
				# Do actions based on label name
				match selected_node_name:
					"LabelPlay":
						switch_menu(character_selection)
						# Change camera zoom
						var default_zoom = get_preview_camera_default_zoom()
						# If we didn't get an error
						if default_zoom != Vector2(-1, -1):
							set_camera_zoom(default_zoom * 0.7)
					"LabelRandomMap":
						map_handler.set_map(map_handler.get_random_map())
					"LabelHowToPlay":
						switch_menu(how_to_play_menu)
					"LabelLevelEditor":
						# Go to editor
						get_tree().change_scene("res://Scenes/Main/LevelEditor/LevelEditor.tscn")
					"LabelCredits":
						# Play credits anim
						if credits_label_anim_player.is_playing():
							credits_label_anim_player.stop()
						credits_label_anim_player.play("scroll_down")
						# Switch menu
						switch_menu(credits_menu)
					"LabelQuit":
						get_tree().quit()
		# If we are in the credits menu
		if current_menu == credits_menu:
			if event.is_action_pressed("ui_cancel"):
				# Switch menu
				switch_menu(main_menu_node)
				
		# If we are in the how to play menu
		if current_menu == how_to_play_menu:
			if event.is_action_pressed("ui_cancel"):
				# Switch menu
				switch_menu(main_menu_node)
		
	# If we are in game
	else:
		if event.is_action_pressed("ui_cancel"):
			quit_match()

func _ready():
	# Remove main title scrollbar
	main_title.get_child(0).modulate.a = 0
	# Remove description scrollbar
	main_menu_selection_description.get_child(0).modulate.a = 0
	# Set the first element of the container as selected
	set_current_selection(0)
	# Play main title animation
	main_title_animation_player.play("highlighting")

func _process(delta):
	if current_selection != -1:
		selector.rect_global_position = lerp(selector.rect_global_position, target_label.rect_global_position + selector_offset, 0.1)

func set_current_selection(_new_selection):
	var new_selection = _new_selection
	
	# Clamp new selection
	if new_selection > menu_options_count - 1:
		new_selection = 0
	if new_selection < 0:
		# Set to last index
		new_selection = menu_options_count - 1
	
	var target = options_container.get_child(new_selection)
	if target != null:
		# Set new target
		target_label = target
		# Play UI Sound
		ui_action_sound.play()
		# Play selector anim
		selector.play_highlight_anim()
		# Set new selection index
		current_selection = new_selection
		# Update description
		update_current_selection_description()

func update_current_selection_description():
	# Get node name from current selection reference
	var selected_node_name = target_label.name
	
	if selected_node_name != null:
		# Do actions based on label name
		match selected_node_name:
			"LabelPlay":
				set_selection_description("Assert your dominance in this FFA showdown")
			"LabelRandomMap":
				set_selection_description("Choose a random map")
			"LabelLevelEditor":
				set_selection_description("Create your own custom maps")
			"LabelHowToPlay":
				set_selection_description("How do I play ????")
			"LabelCredits":
				set_selection_description("People who contributed to this game")
			"LabelQuit":
				set_selection_description("Quit ?")

func switch_menu(new_menu : Control):
	if current_menu != null:
		current_menu.visible = false
	new_menu.visible = true
	current_menu = new_menu

func hide_all_player_hud():
	for hud in player_hud_list:
		hud.visible = false
		
func show_all_player_hud():
	for hud in player_hud_list:
		hud.visible = true

func start_game():
	# Switch to main menu
	switch_menu(main_menu_node)
	# Hide main menu
	main_menu_node.visible = false
	
	# Get game camera
	var game_camera = map_handler.get_game_camera()
	if game_camera != null:
		# Refresh player container on the camera
		game_camera.refresh_player_container()
		# Switch camera
		Globals.set_camera(game_camera)
	
	# Show HUD
	players_hud.visible = true
	
	# Change in game state
	Globals.set_in_game_state(true)

func quit_match():
	# Delete all players
	player_container.vanish_players()
	# Get preview camera
	var preview_camera = map_handler.get_preview_camera()
	if preview_camera != null:
		# Switch camera
		Globals.set_camera(preview_camera)
	
	# Hide HUD
	players_hud.visible = false
	# Show menu
	main_menu_node.visible = true
	# Set in game state
	Globals.set_in_game_state(false)

func set_selection_description(description : String):
	main_menu_selection_description.bbcode_text = "[tornado radius=2 freq=8]" + description + "[/tornado]"

func get_main_menu_node():
	return main_menu_node

func play_ui_action_sound():
	ui_action_sound.play()

func get_character_selection_menu():
	return character_selection

func set_camera_zoom(new_zoom):
	var camera_to_set = map_handler.get_preview_camera()
	if camera_to_set == null:
		return
		
	camera_to_set.set_camera_zoom(new_zoom)
	
func reset_camera_zoom():
	var camera_to_reset = map_handler.get_preview_camera()
	if camera_to_reset == null:
		return
		
	camera_to_reset.reset_camera_zoom()
	
func get_preview_camera_default_zoom():
	if map_handler == null:
		return Vector2(-1, -1)
		
	return map_handler.get_preview_camera_default_zoom()
