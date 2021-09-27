extends TextureRect

onready var node_name = $NodeName

export (PackedScene) var scene_to_spawn
# Displayed text for the node
export (String) var displayed_name = ""
export (float) var texture_scale = 1

# TILE VARIABLES
export (bool) var is_tile = false
export (String) var tile_name = ""

signal item_clicked(sender)

func _ready():
	connect("gui_input", self, "_on_gui_input")
	# Set the name of the node
	set_node_name(displayed_name)
	
func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			# Emit signal when the node gets clicked
			emit_signal("item_clicked", self)

func set_node_name(_new_name : String):
	node_name.text = _new_name

func get_texture_scale():
	return texture_scale

func get_texture():
	return texture

func get_scene_to_spawn():
	return scene_to_spawn

func is_tile():
	return is_tile

func get_tile_name():
	return tile_name
