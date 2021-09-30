extends Node2D
class_name Item

# Holds weapon name
export (String) var item_name = ""
# Holds position of the gun when equiping
export (Vector2) var equip_pos = Vector2.ZERO

#### References #####
var map_handler = null

# Hold reference to the player that is holding the weapon
var owner_player = null

func _ready():
	if Globals.get_in_editor_state():
		map_handler = get_node("/root/LevelEditor/MapHolder")
	else:
		map_handler = get_node("/root/SceneHandler/MapHandler")

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
