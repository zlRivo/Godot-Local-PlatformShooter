extends Node2D
class_name EditorObject
# Class adding extra features for the node in the editor

# Know if the user is hovering the object
var is_mouse_hovering = false

var mouse_hover_area = Area2D.new()
# Shape where it will detect if the mouse is hovering
export (RectangleShape2D) var mouse_hover_shape

func _ready():
	# Connect signals
	mouse_hover_area.connect("mouse_entered", self, "_on_mouse_entered")
	mouse_hover_area.connect("mouse_exited", self, "_on_mouse_exited")
	
	if mouse_hover_shape == null:
		# Default shape
		mouse_hover_shape = RectangleShape2D.new()
		mouse_hover_shape.extents = Vector2(9, 9)
	
	# Set area shape
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = mouse_hover_shape
	mouse_hover_area.add_child(collision_shape)
	
	# Add area to scene
	add_child(mouse_hover_area)

func _physics_process(delta):
	if Globals.get_in_editor_state() and not Globals.get_testing_map_state() and is_mouse_hovering:
		if Input.is_action_pressed("editor_remove"):
			delete_editor_object()

# Delete the object
func delete_editor_object():
	queue_free()

func get_mouse_hovering():
	return is_mouse_hovering

func _on_mouse_entered():
	is_mouse_hovering = true
	
func _on_mouse_exited():
	is_mouse_hovering = false
