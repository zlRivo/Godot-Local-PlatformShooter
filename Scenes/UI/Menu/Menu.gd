extends CanvasLayer

onready var map_handler = get_node("/root/SceneHandler/MapHandler")

# References
onready var main_title = $MainMenuNode/MainTitle
onready var main_title_animation_player = $MainMenuNode/MainTitle/AnimationPlayer
onready var character_selection = $CharacterSelection
onready var main_menu_node = $MainMenuNode
onready var options_container = $MainMenuNode/OptionsContainer
onready var selector = $MainMenuNode/Selector

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
	# Main menu
	if main_menu_node.visible:
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
					print("HowToPlay")
				"LabelCredits":
					print("Credits")
				"LabelQuit":
					get_tree().quit()

	# Character selection
	if character_selection.visible:
		if event.is_action_pressed("ui_cancel"):
			# Play UI Sound
			ui_action_sound.play()
			# Switch to main menu
			switch_menu(main_menu_node)
			# Reset camera zoom
			reset_camera_zoom()

func _ready():
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

func switch_menu(new_menu : Control):
	if current_menu != null:
		current_menu.visible = false
	new_menu.visible = true
	current_menu = new_menu

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
