extends Control

# References
onready var file_menu_button = $GUI/MenuBar/HBoxContainer/MenuButtonFile
onready var menu_bar = $GUI/MenuBar
onready var button_action_container = $GUI/ButtonActionContainer
onready var options_container = $GUI/OptionsContainer

onready var item_selection = $GUI/ItemSelection
onready var cursor_object_preview = $CursorObjectPreview
onready var gui = $GUI
onready var grid = $Grid

onready var map_holder = $MapHolder
onready var player_container = $PlayerContainer
onready var editor_camera = $EditorCamera

# Popups
onready var popup_container = $GUI/Popups
onready var unsave_quit_confirm_popup = $GUI/Popups/UnsaveQuitConfirm
onready var unsave_return_to_game_popup = $GUI/Popups/UnsaveReturnToGamePopup
onready var no_save_popup = $GUI/Popups/NoSavePopup

var player_scene = preload("res://Scenes/Instances/Player/Player.tscn")

# Variables
var save_file_path = "" # Contain the current save file path

# Know whether the last changes were saved
var _unsaved_changes = false

# Hold the scene that will be placed on the map
var current_selection_scene = null
# Know if the current selection is a tile
var current_selection_is_tile = null
var current_selection_tile_name = ""
var tile_to_spawn = null

var placing_objects = false
var removing_objects = false

var cursor_hitting_ui = false
var panning = false

var is_placing_object = false
var is_removing_object = false

var test_mode_map_save = null

const GRID_INCREMENT = 18
const MAX_CAMERA_ZOOM = 0.05
const MIN_CAMERA_ZOOM = 1

var map_references = {
	"game_camera": null,
	"preview_camera": null,
	"player_spawns": null,
	"items_container": null,
	"decal_container": null,
	"projectile_container": null,
	"tilemap": null
}

func _ready():
	# Set in editor state
	Globals.set_in_editor_state(true)
	# Pause the game
	Physics2DServer.set_active(false)
	# get_tree().paused = true
	# Connect signals
	connect_all_mouse_entered_exit()
	item_selection.connect("item_clicked", self, "_on_item_selection_clicked")
	file_menu_button.get_popup().connect("id_pressed", self, "_on_file_id_pressed")
	map_holder.connect("map_changed", self, "_on_map_changed")
	cursor_object_preview.connect("cursor_moved", self, "_on_cursor_moved")
	
	unsave_quit_confirm_popup.connect("confirmed", self, "_on_unsave_popup_confirmed")
	unsave_return_to_game_popup.connect("confirmed", self, "_on_unsave_return_to_game_confirmed")
	# Set to windowed
	OS.set_window_fullscreen(false)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel_0"):
		if Globals.get_testing_map_state():
			exit_testing_mode()
	
	if Globals.get_testing_map_state():
		return
		
	# Camera panning
	if panning:
		if event is InputEventMouseMotion:
			editor_camera.global_position -= event.relative * editor_camera.zoom
			return
	if event.is_action_pressed("editor_toggle_items"):
		# Remove focus
		var current_focus_control = get_focus_owner()
		if current_focus_control:
			current_focus_control.release_focus()

func _input(event):
	if Globals.get_testing_map_state():
		return
		
	if event.is_action_released("editor_place"):
		is_placing_object = false
	if event.is_action_released("editor_remove"):
		is_removing_object = false
	
	if event.is_action_pressed("editor_place"):
		is_placing_object = true
		place_object()
	if event.is_action_pressed("editor_remove"):
		is_removing_object = true
		remove_object()
	if event.is_action_pressed("editor_zoom_in"):
		zoom_in()
	if event.is_action_pressed("editor_zoom_out"):
		zoom_out()
	if event.is_action_pressed("editor_toggle_items"):
		item_selection.toggle_menu()

func set_unsaved_changes(_new_value):
	_unsaved_changes = _new_value

func zoom_in():
	var zoom_increment = (editor_camera.zoom.x - MAX_CAMERA_ZOOM) / 4
	editor_camera.zoom.x = max(MAX_CAMERA_ZOOM, editor_camera.zoom.x - zoom_increment)
	editor_camera.zoom.y = max(MAX_CAMERA_ZOOM, editor_camera.zoom.y - zoom_increment)

func zoom_out():
	var zoom_increment = (MIN_CAMERA_ZOOM - editor_camera.zoom.x) / 4
	editor_camera.zoom.x = min(MIN_CAMERA_ZOOM, editor_camera.zoom.x + zoom_increment)
	editor_camera.zoom.y = min(MIN_CAMERA_ZOOM, editor_camera.zoom.y + zoom_increment)

# Loops through all the control nodes in the gui and connect the mouse entered/exit signals
func connect_all_mouse_entered_exit():
	for c in Globals.get_children_recursive(gui):
		# If the iterated node is of is of type Control
		if c is Control:
			# Connect the signals
			c.connect("mouse_entered", self, "_on_gui_mouse_entered")
			c.connect("mouse_exited", self, "_on_gui_mouse_exited")

# When the object cursor moves
func _on_cursor_moved():
	if Globals.get_testing_map_state():
		return
	
	if is_placing_object and not is_removing_object:
		place_object()
		
	if is_removing_object and not is_placing_object:
		remove_object()

# Enter the testing mode
func enter_testing_mode():
	if Globals.get_testing_map_state():
		return
	
	# If there is no spawn container
	var player_spawns = map_holder.get_player_spawns()
	if player_spawns == null:
		return
	
	# If there is no player spawn
	if player_spawns.get_child_count() == 0:
		# Show popup
		no_save_popup.show_modal(true)
		return
	
	# Save the map
	test_mode_map_save = map_holder.pack_map()
	# If the map didn't correctly save do nothing
	if test_mode_map_save == null:
		return
	
	Globals.set_testing_map_state(true)
	# Hide GUI
	hide_gui()
	# Switch the camera
	switch_to_game_camera()
	# Spawn the player
	spawn_test_player()
	# Refresh game camera targets
	var game_camera = map_holder.get_game_camera()
	if game_camera != null:
		# Refresh player container on the camera
		game_camera.refresh_player_container()
		
	# Enable physics
	Physics2DServer.set_active(true)
	
	# Hide player spawns
	hide_player_spawns()

# Exit the testing mode
func exit_testing_mode():
	if not Globals.get_testing_map_state():
		return
	
	# Delete the players
	for p in player_container.get_children():
		player_container.remove_child(p)
	
	# Refresh game camera targets
	var game_camera = map_holder.get_game_camera()
	if game_camera != null:
		# Refresh player container on the camera
		game_camera.refresh_player_container()
	
	# Show player spawns
	show_player_spawns()
	# Disable physics
	Physics2DServer.set_active(false)
	# Switch camera
	switch_to_editor_camera()
	# Show GUI
	show_gui()
	Globals.set_testing_map_state(false)
	# Load map save
	if test_mode_map_save != null:
		map_holder.set_map(test_mode_map_save)

func hide_player_spawns():
	var player_spawns = map_holder.get_player_spawns()
	if player_spawns == null:
		return
		
	for spawn in player_spawns.get_children():
		spawn.visible = false

func show_player_spawns():
	var player_spawns = map_holder.get_player_spawns()
	if player_spawns == null:
		return
		
	for spawn in player_spawns.get_children():
		spawn.visible = true

func spawn_test_player():
	# If there is no spawn container or no player spawn
	var player_spawns = map_holder.get_player_spawns()
	if player_spawns == null or player_spawns.get_child_count() == 0:
		return
		
	var player = player_scene.instance()
	# Spawn the player
	player_container.add_child(player)
	# Initialize player
	player.map_handler = get_node("/root/LevelEditor/MapHolder")
	player.player_container = get_node("/root/LevelEditor/PlayerContainer")
	player.init_player(0, 0, player_spawns, null)

func _on_map_changed():
	refresh_map_references()

# Set all the map references
func refresh_map_references():
	map_references = {
		"game_camera": map_holder.get_game_camera(),
		"preview_camera": map_holder.get_preview_camera(),
		"player_spawns": map_holder.get_player_spawns(),
		"items_container": map_holder.get_items_container(),
		"decal_container": map_holder.get_decal_container(),
		"projectile_container": map_holder.get_projectile_container(),
		"tilemap": map_holder.get_tilemap()
	}

func _on_item_selection_clicked(sender):
	# Get data from the clicked item
	current_selection_scene = sender.get_scene_to_spawn()
	cursor_object_preview.texture = sender.get_texture()
	cursor_object_preview.scale.x = sender.get_texture_scale()
	cursor_object_preview.scale.y = sender.get_texture_scale()
	current_selection_is_tile = sender.is_tile()
	current_selection_tile_name = sender.get_tile_name()
	
	# Set the current tile
	if current_selection_is_tile:
		# Get tilemap
		var tilemap = map_holder.get_tilemap()
		if tilemap == null:
			return
		
		# Get what tile we have to spawn with the name
		tile_to_spawn = tilemap.tile_set.find_tile_by_name(current_selection_tile_name)
	else:
		tile_to_spawn = null

func _process(delta):
	# Align cursor to grid
	if not cursor_hitting_ui:
		var mouse_position = get_global_mouse_position()
		cursor_object_preview.global_position.x = Globals.round_by_step(mouse_position.x, GRID_INCREMENT) - GRID_INCREMENT / 2
		cursor_object_preview.global_position.y = Globals.round_by_step(mouse_position.y, GRID_INCREMENT) - GRID_INCREMENT / 2
	
	panning = Input.is_action_pressed("editor_pan")
	if panning:
		Input.set_default_cursor_shape(CURSOR_MOVE)
	else:
		Input.set_default_cursor_shape(CURSOR_ARROW)

func disable_control_node(_node : Control):
	_node.visible = false
	_node.set_process_input(false)
	_node.set_process_unhandled_input(false)
	_node.set_process_unhandled_key_input(false)

func enable_control_node(_node : Control):
	_node.visible = true
	_node.set_process_input(true)
	_node.set_process_unhandled_input(true)
	_node.set_process_unhandled_key_input(true)

func show_gui():
	# Show grid
	grid.visible = true
	
	# Enable gui nodes
	enable_control_node(item_selection)
	enable_control_node(menu_bar)
	enable_control_node(button_action_container)
	enable_control_node(options_container)

func hide_gui():
	# Hide grid
	grid.visible = false
	
	# Disblae gui nodes
	disable_control_node(item_selection)
	disable_control_node(menu_bar)
	disable_control_node(button_action_container)
	disable_control_node(options_container)

func place_object():
	# If the cursor is hitting the UI or we didn't selected any object
	if cursor_hitting_ui or current_selection_is_tile == null:
		return
	
	# If the selected object is not a tile
	if not current_selection_is_tile:
		
		if current_selection_scene == null:
			return
		
		# Add to game world
		var instance = current_selection_scene.instance()
		instance.global_position = cursor_object_preview.global_position
		
		if instance is ItemPickup:
			var items_container = map_holder.get_items_container()
			if items_container != null:
				items_container.add_child(instance)
				# Inform that there was changes
				set_unsaved_changes(true)
				
		# If the instance is a player spawn
		if instance.is_in_group("PlayerSpawn"):
			var player_spawns_container = map_holder.get_player_spawns()
			if player_spawns_container != null:
				player_spawns_container.add_child(instance)
				# Inform that there was changes
				set_unsaved_changes(true)
		
		# If the instance is a terrain item
		if instance.is_in_group("TerrainItem"):
			var terrain_items_container = map_holder.get_terrain_items_container()
			if terrain_items_container != null:
				terrain_items_container.add_child(instance)
				# Inform that there was changes
				set_unsaved_changes(true)
		
	else:
		# If we have no tile to spawn or no tilemap, quit func
		if tile_to_spawn == null or map_references["tilemap"] == null:
			return
		
		# Get cursor positions
		var last_cursor_pos = cursor_object_preview.get_last_cursor_position()
		var current_cursor_pos = cursor_object_preview.global_position
		
		# Get tilemap
		var tilemap = map_references["tilemap"]
		var coord_to_place = tilemap.world_to_map(current_cursor_pos)
		
		"""
		var coord_from = tilemap.world_to_map(last_cursor_pos)
		var coord_to = tilemap.world_to_map(current_cursor_pos)
		# Y Difference between the two positions
		var divisor_y = max(coord_from.y, coord_to.y) - min(coord_from.y, coord_to.y) + 1
		"""
		
		# Set the cell in the tilemap
		tilemap.set_cell(coord_to_place.x, coord_to_place.y, tile_to_spawn)
		# Refresh autotiling
		tilemap.update_bitmask_area(coord_to_place)
					
		
		set_unsaved_changes(true)

func remove_object():
	# Quit function
	if cursor_hitting_ui:
		return
	
	# If we have no tilemap, quit func
	if map_references["tilemap"] == null:
		return
	
	# Get tilemap
	var tilemap = map_references["tilemap"]
	# Translate world position to gridmap coord
	var coord_to_remove = tilemap.world_to_map(cursor_object_preview.global_position)
	# Remove the cell in the tilemap
	tilemap.set_cell(coord_to_remove.x, coord_to_remove.y, -1)
	# Refresh autotiling
	tilemap.update_bitmask_area(coord_to_remove)
	
	set_unsaved_changes(true)

func switch_to_game_camera():
	var game_camera = map_holder.get_game_camera()
	if game_camera != null:
		Globals.set_camera(game_camera)

func switch_to_editor_camera():
	Globals.set_camera(editor_camera)

func _on_gui_mouse_entered():
	cursor_hitting_ui = true
	# Hide cursor
	cursor_object_preview.visible = false
	
func _on_gui_mouse_exited():
	cursor_hitting_ui = false
	# Show cursor
	cursor_object_preview.visible = true

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
	if _unsaved_changes:
		unsave_quit_confirm_popup.show_modal(true)
		yield(unsave_quit_confirm_popup, "popup_hide")
	else:
		get_tree().quit()

func return_to_game():
	if _unsaved_changes:
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

# Show grid checkbox
func _on_ShowGridCbx_toggled(button_pressed):
	grid.set_state(button_pressed)


func _on_ButtonGoToZero_pressed():
	editor_camera.position = Vector2.ZERO


func _on_ButtonTestMap_pressed():
	enter_testing_mode()
