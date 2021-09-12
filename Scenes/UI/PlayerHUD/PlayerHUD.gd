extends Control

# References
onready var health_bar = $HealthBar
onready var icon = $Icon
onready var player_name = $PlayerName

var displayed_health = 3

# Initialize node
func init_hud(new_name, new_icon, starting_health):
	displayed_health = starting_health
	update_health(starting_health)
	set_player_name(new_name)
	set_player_icon(new_icon)

func update_health(value):
	# Call health bar method
	health_bar.update_health(value)
	
	# Play hurt anim if value is lower than displayed or something
	# ...
	
	displayed_health = value

func set_player_name(name):
	player_name.text = name

func set_player_icon(new_icon : Texture):
	icon.texture = new_icon
