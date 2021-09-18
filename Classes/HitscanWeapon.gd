extends RangeWeapon
class_name HitscanWeapon

# Raycast
export (NodePath) var raycast_path
onready var raycast = get_node_or_null(raycast_path)

# Bullet trail lifetime
export (float) var bullet_trail_lifetime = 1

var bullet_trail_scene = preload("res://Scenes/Instances/BulletTrail/BulletTrail.tscn")

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

func fire():
	# Start firing cooldown if not active
	if fire_cooldown_timer_finished:
		# Quit function if there is no raycast
		if raycast == null:
			return
		
		# If we have enough ammo to shoot
		if ammo_in_mag > 0:
			if not unlimited_ammo:
				# Remove one bullet
				ammo_in_mag -= 1
			
			# Camera shake
			Globals.shake_camera(camera_shake, 0.1)
			
			
			# Get decal container
			var decal_container = map_handler.get_decal_container()
			# If we can spawn the bullet trail
			if decal_container != null:
				# Create bullet trail
				var bullet_trail = bullet_trail_scene.instance()
				# Set the position
				bullet_trail.global_position = global_position
				# Bullet movement vector
				var bullet_trail_direction = Vector2.ZERO
				# If there is an owner of the gun
				if owner_player != null:
					# If the owner is a player
					if owner_player.is_in_group("Player"):
						# Set the velocity of the bullet based on his x scale
						bullet_trail_direction.x = owner_player.get_x_scale()
				
				# Initialize the bullet trail
				bullet_trail.init_trail(bullet_trail_direction, 2, owner_player)
			
				# Spawn it
				decal_container.add_child(bullet_trail)
			
			# Animation
			if animation_player != null:
				if animation_player.is_playing():
					animation_player.stop()
				animation_player.play("fire")
				
			# Weapon sound
			if attack_sound != null:
				attack_sound.play()
			
			# Gun interaction
			if raycast.is_colliding():
				# Get the collider
				var first_collider = raycast.get_collider()
				# If we collided with a player make him take damage
				if first_collider.is_in_group("Player"):
					var player_health = first_collider.get_health()
					first_collider.set_health(player_health - damage, owner_player)
			
			# Start cooldown
			fire_cooldown_timer.start()
			fire_cooldown_timer_finished = false

func _on_fire_cooldown_timer_finished():
	fire_cooldown_timer_finished = true

func get_item_data():
	return {
		"name": item_name,
		"equip_pos": equip_pos,
		"ammo_in_mag": ammo_in_mag
	}
