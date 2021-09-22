extends Node2D
class_name Item

# Holds weapon name
export (String) var item_name = ""
# Holds position of the gun when equiping
export (Vector2) var equip_pos = Vector2.ZERO

#### References #####
onready var map_handler = get_node("/root/SceneHandler/MapHandler")

# Hold reference to the player that is holding the weapon
var owner_player = null

# Delete the item from the map
func delete_item():
	# Get items container
	var items_container = map_handler.get_items_container()
	# Remove the gun from the scene
	if items_container != null:
		items_container.remove_child(self)
	else:
		queue_free()

func get_item_data():
	return {
		"name": item_name
	}
