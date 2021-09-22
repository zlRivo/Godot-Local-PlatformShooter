extends ProjectileWeapon

func fire():
	# Call fire on parent class
	.fire()
	
	# Quit function if there is no spawn position or node to spawn
	if spawn_position == null or projectile_to_spawn == null:
		return
	
	# If we have enough ammo
	if ammo_in_mag > 0:
		# If we the shoot cooldown has ended
		if fire_cooldown_timer_finished:
			# If we got a projectile to spawn
			if last_shot_projectile != null:
				var projectile_container = map_handler.get_projectile_container()
				# If we have a container to spawn the projectile in
				if projectile_container != null:
					# Projectile movement vector
					var projectile_trail_direction = Vector2.ZERO
					# If there is an owner of the gun
					if owner_player != null:
						# If the owner is a player
						if owner_player.is_in_group("Player"):
							# Set the velocity of the projectile based on his x scale
							projectile_trail_direction.x = owner_player.get_x_scale()
							
					# Initialize the projectile
					last_shot_projectile.init_projectile(projectile_trail_direction, damage, owner_player)
		
					# Spawn in the game world
					projectile_container.add_child(last_shot_projectile)
					
					.decrement_ammo()
					
			# Start the firing cooldown for the weapon
			.start_fire_cooldown()
	
