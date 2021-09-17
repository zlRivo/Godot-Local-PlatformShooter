extends Weapon
class_name HitscanWeapon

export (float) var fire_rate = 0
export (float) var damage = 3

# Raycast
export (NodePath) var raycast_path
onready var raycast = get_node_or_null(raycast_path)

# Timer used for attack speed
var fire_cooldown_timer = Timer.new()

# Know if the firing cooldown is finished
var fire_cooldown_timer_finished = true

func _ready():
	# Initialize timer
	fire_cooldown_timer.one_shot = true
	fire_cooldown_timer.wait_time = fire_rate
	# Connect timer signal
	fire_cooldown_timer.connect("timeout", self, "_on_fire_cooldown_timer_finished")
	# Add to scene
	add_child(fire_cooldown_timer)

func attack():
	# Start firing cooldown if not active
	if fire_cooldown_timer_finished:
		# Quit function if there is no raycast
		if raycast == null:
			return
		
		# Animation
		if animation_player != null:
			if animation_player.is_playing():
				animation_player.stop()
			animation_player.play("fire")
		
		# Gun interaction
		if raycast.is_colliding():
			# Get the collider
			var first_collider = raycast.get_collider()
			# If we collided with a player make him take damage
			if first_collider.is_in_group("Player"):
				var player_health = first_collider.get_health()
				first_collider.set_health(player_health, owner_player)
		
		# Start cooldown
		fire_cooldown_timer.start()
		fire_cooldown_timer_finished = false

func _on_fire_cooldown_timer_finished():
	fire_cooldown_timer_finished = true
