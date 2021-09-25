extends RigidBody2D
class_name ItemPickup

export (String) var item_name = ""

var map_handler = null

func _ready():
	var current_scene_name = get_tree().current_scene.name
	match current_scene_name:
		"SceneHandler":
			map_handler = get_node("/root/SceneHandler/MapHandler")
		"LevelEditor":
			map_handler = get_node("/root/LevelEditor/MapHolder")

func throw_object(direction : Vector2):
	apply_central_impulse(direction)

func delete_item():
	# Get items container
	var items_container = map_handler.get_items_container()
	# Remove the gun from the scene
	if items_container != null:
		items_container.remove_child(self)
	else:
		queue_free()

func get_item_pickup_data():
	return {
		"name": item_name
	}
