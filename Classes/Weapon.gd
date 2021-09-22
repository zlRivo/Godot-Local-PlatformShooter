extends Item
class_name Weapon

#### References #####

# Animation player
export (NodePath) var animation_player_path
onready var animation_player = get_node_or_null(animation_player_path)

# Attack sound
export (NodePath) var attack_sound_path
onready var attack_sound = get_node_or_null(attack_sound_path)
