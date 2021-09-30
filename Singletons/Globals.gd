extends Node

var active_camera = null
var default_camera_zoom = 1
onready var target_camera_zoom = default_camera_zoom

const GRID_INCREMENT = 18

# Know if the player is in game
var in_game = false
var in_editor = false
var testing_map = false
var editor_tree_ready = false

var collisions_shown = false

# Gets all the nodes from a parent
func get_children_recursive(parent : Node):
	var child_list = []
	for c in parent.get_children():
		child_list.append(c)
		if c.get_child_count() > 0:
			for c_2 in get_children_recursive(c):
				child_list.append(c_2)
	return child_list

func get_node_by_position(_parent : Node2D, _position : Vector2):
	var space_state = _parent.get_world_2d().direct_space_state
	# Node on the positions
	var nodes = space_state.intersect_point(_position)
	return nodes

func round_by_step(_to_round : float, _step : float):
	return ceil(_to_round / _step) * _step

func set_editor_tree_ready(value):
	editor_tree_ready = value
	
func is_editor_tree_ready():
	return editor_tree_ready

func set_testing_map_state(_new_state):
	testing_map = _new_state

func get_testing_map_state():
	return testing_map

func set_in_editor_state(_new_state):
	in_editor = _new_state

func get_in_editor_state():
	return in_editor

func set_camera_process(new_state):
	if active_camera != null:
		active_camera.set_process(new_state)

func set_camera(new_cam : Camera2D):
	new_cam.current = true
	active_camera = new_cam
	default_camera_zoom = new_cam.zoom

func shake_camera(new_shake_amount, shake_time = 0.4):
	if active_camera == null:
		return
		
	if active_camera.has_method("shake"):
		active_camera.shake(new_shake_amount, shake_time)

# Know if the player is in game
func is_in_game():
	return in_game

func set_in_game_state(new_state):
	in_game = new_state
