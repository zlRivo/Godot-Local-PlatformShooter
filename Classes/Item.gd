extends Node2D
class_name Item

# Holds weapon name
export (String) var item_name = ""
# Holds position of the gun when equiping
export (Vector2) var equip_pos = Vector2.ZERO

#### References #####
# Hold reference to the player that is holding the weapon
var owner_player = null

func get_item_data():
	return {
		"name": item_name,
		"equip_pos": equip_pos
	}
