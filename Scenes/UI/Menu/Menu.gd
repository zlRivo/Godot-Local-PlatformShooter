extends CanvasLayer

onready var map_handler = get_node("/root/SceneHandler/MapHandler")

# References
onready var main_title = $MainMenuNode/MainTitle
onready var character_selection = $CharacterSelection
onready var main_menu_node = $MainMenuNode
onready var options_container = $MainMenuNode/OptionsContainer
onready var selector = $MainMenuNode/Selector

# Current menu reference
onready var current_menu = main_menu_node

export (Vector2) var selector_offset = Vector2(-40, 0)
onready var menu_options_count = options_container.get_child_count()
var current_selection = -1
var target_label = null

func _input(event):
	# If we can see the menu
	if main_menu_node.visible:
		if event.is_action_pressed("ui_down"):
			set_current_selection(current_selection + 1)
		if event.is_action_pressed("ui_up"):
			set_current_selection(current_selection - 1)
		if event.is_action_pressed("ui_accept"):
			# Get node name from current selection reference
			var selected_node_name = target_label.name
			
			# Do actions based on label name
			match selected_node_name:
				"LabelPlay":
					switch_menu(character_selection)
				"LabelRandomMap":
					map_handler.set_map(map_handler.get_random_map())
				"LabelHowToPlay":
					print("HowToPlay")
				"LabelCredits":
					print("Credits")
				"LabelQuit":
					get_tree().quit()

func _ready():
	# Set the first element of the container as selected
	set_current_selection(0)
	
func _process(delta):
	if current_selection != -1:
		selector.rect_global_position = lerp(selector.rect_global_position, target_label.rect_global_position + selector_offset, 0.1)

func set_current_selection(_new_selection):
	var target = options_container.get_child(_new_selection)
	if target != null:
		# Set new target
		target_label = target
		# Set new selection index
		current_selection = _new_selection

func switch_menu(new_menu : Control):
	if current_menu != null:
		current_menu.visible = false
	new_menu.visible = true
	current_menu = new_menu
