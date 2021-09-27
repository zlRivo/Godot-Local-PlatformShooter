extends EditorObject
class_name ItemPickup

export (String) var item_name = ""

var map_handler = null

# Contain reference to ourself with the specified type
var body : RigidBody2D

func _init():
	var _self = self
	body = _self

func _ready():
	var current_scene_name = body.get_tree().current_scene.name
	match current_scene_name:
		"SceneHandler":
			map_handler = body.get_node("/root/SceneHandler/MapHandler")
		"LevelEditor":
			map_handler = body.get_node("/root/LevelEditor/MapHolder")

func throw_object(direction : Vector2):
	body.apply_central_impulse(direction)

func delete_item():
	# Get items container
	var items_container = map_handler.get_items_container()
	# Remove the gun from the scene
	if items_container != null:
		items_container.remove_child(self)
	else:
		body.queue_free()

func get_item_pickup_data():
	return {
		"name": item_name
	}
