extends RangeWeapon
class_name ProjectileWeapon

export (PackedScene) var projectile_to_spawn

# Projectile spawn position
export (NodePath) var spawn_position_path
onready var spawn_position = get_node_or_null(spawn_position_path)

# Hold last shot projectile reference for daughter class
var last_shot_projectile = null

func fire():
	# Default value
	last_shot_projectile = null
	
	# Start firing cooldown if not active
	if fire_cooldown_timer_finished:
		# Quit function if there is no spawn position or node to spawn
		if spawn_position == null or projectile_to_spawn == null:
			return
		
		# If we have enough ammo to shoot
		if ammo_in_mag > 0:
			
			# Camera shake
			Globals.shake_camera(camera_shake, 0.1)
			
			# Animation
			if animation_player != null:
				if animation_player.is_playing():
					animation_player.stop()
				animation_player.play("fire")
				
			# Weapon sound
			if attack_sound != null:
				attack_sound.play()
			
			# Create projectile
			var new_projectile = projectile_to_spawn.instance()
			# Set projectile position
			new_projectile.global_position = spawn_position.global_position
				
			# Set last shot projectile reference
			last_shot_projectile = new_projectile

func decrement_ammo():
	if not unlimited_ammo:
		# Remove one bullet
		ammo_in_mag -= 1

func start_fire_cooldown():
	# Start cooldown
	fire_cooldown_timer.start()
	fire_cooldown_timer_finished = false
