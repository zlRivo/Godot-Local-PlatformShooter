extends TextureRect

export (PackedScene) var scene_to_spawn

signal item_clicked(sender)

func _ready():
	connect("gui_input", self, "_on_gui_input")
	
func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		# Emit signal when the node gets clicked
		emit_signal("item_clicked", self)

func get_texture():
	return texture

func get_scene_to_spawn():
	return scene_to_spawn
