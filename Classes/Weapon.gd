extends Node2D
class_name Weapon

# Holds weapon name
export (String) var weapon_name
# Holds position of the gun when equiping
export (Vector2) var equip_pos

#### References #####
# Hold reference to the player that is holding the weapon
var owner_player = null

# Animation player
export (NodePath) var animation_player_path
onready var animation_player = get_node_or_null(animation_player_path)
