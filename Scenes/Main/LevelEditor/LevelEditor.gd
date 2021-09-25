extends Control

# References
onready var file_menu_button = $GUI/ColorRect/HBoxContainer/MenuButtonFile

onready var button_toggle_items_menu = $GUI/ButtonToggleItemsMenu
onready var item_selection = $GUI/ItemSelection
onready var cursor_object_preview = $CursorObjectPreview
onready var gui = $GUI

onready var map_holder = $MapHolder

# Popups
onready var popup_container = $GUI/Popups
onready var unsave_quit_confirm_popup = $GUI/Popups/UnsaveQuitConfirm
onready var unsave_return_to_game_popup = $GUI/Popups/UnsaveReturnToGamePopup

# Variables
var save_file_path = "" # Contain the current save file path

# Know whether the last changes were saved
var unsaved_changes = true

# Hold the scene that will be placed on the map
var current_selection_scene = null

var cursor_hitting_ui = false

const GRID_INCREMENT = 18

func _ready():
	# Pause the game
	get_tree().paused = true
	# Connect signals
	connect_all_mouse_entered_exit()
	item_selection.connect("item_clicked", self, "_on_item_selection_clicked")
	file_menu_button.get_popup().connect("id_pressed", self, "_on_file_id_pressed")
	
	unsave_quit_confirm_popup.connect("confirmed", self, "_on_unsave_popup_confirmed")
	unsave_return_to_game_popup.connect("confirmed", self, "_on_unsave_return_to_game_confirmed")
	# Set to windowed
	OS.set_window_fullscreen(false)

func _input(event):
	if event.is_action_pressed("editor_place"):
		place_object()

# Loops through all the control nodes in the gui and connect the mouse entered/exit signals
func connect_all_mouse_entered_exit():
	for c in Globals.get_children_recursive(gui):
		# If the iterated node is of is of type Control
		if c is Control:
			# Connect the signals
			c.connect("mouse_entered", self, "_on_gui_mouse_entered")
			c.connect("mouse_exited", self, "_on_gui_mouse_exited")

func _on_item_selection_clicked(sender):
	# Get data from the clicked item
	current_selection_scene = sender.get_scene_to_spawn()
	cursor_object_preview.texture = sender.get_texture()

func _process(delta):
	var mouse_position = get_global_mouse_position()
	cursor_object_preview.position.x = Globals.round_by_step(mouse_position.x, GRID_INCREMENT) - GRID_INCREMENT / 2
	cursor_object_preview.position.y = Globals.round_by_step(mouse_position.y, GRID_INCREMENT) - GRID_INCREMENT / 2

func place_object():
	if cursor_hitting_ui or current_selection_scene == null:
		return
	
	# Add to game world
	var instance = current_selection_scene.instance()
	instance.global_position = cursor_object_preview.global_position
	
	if instance is ItemPickup:
		var items_container = map_holder.get_items_container()
		if items_container != null:
			items_container.add_child(instance)

func _on_gui_mouse_entered():
	cursor_hitting_ui = true
	
func _on_gui_mouse_exited():
	cursor_hitting_ui = false

# When scene gets added to the tree or switched to
func _enter_tree():
	# Show the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_ButtonToggleItemsMenu_pressed():
	item_selection.toggle_menu()

func _on_file_id_pressed(id):
	var text = file_menu_button.get_popup().get_item_text(id)
	match text:
		"Quit":
			quit_editor()
		"Return to game":
			return_to_game()

func quit_editor():
	if unsaved_changes:
		unsave_quit_confirm_popup.show_modal(true)
		yield(unsave_quit_confirm_popup, "popup_hide")
	else:
		get_tree().quit()

func return_to_game():
	if unsaved_changes:
		unsave_return_to_game_popup.show_modal(true)
		yield(unsave_return_to_game_popup, "popup_hide")
	else:
		# Unpause the game
		get_tree().paused = false
		get_tree().change_scene("res://Scenes/Main/SceneHandler/SceneHandler.tscn")

func _on_unsave_popup_confirmed():
	get_tree().quit()

func _on_unsave_return_to_game_confirmed():
	# Unpause the game
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/Main/SceneHandler/SceneHandler.tscn")