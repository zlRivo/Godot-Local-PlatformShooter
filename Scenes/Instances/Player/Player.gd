extends KinematicBody2D

# References
onready var sprite = $Sprite
onready var animation_tree = $AnimationTree
onready var player_label = $PlayerIndicator/PlayerLabel
onready var player_indicator = $PlayerIndicator
onready var collision_shape = $CollisionShape2D
onready var stomp_detector = $StompDetector
onready var visible_timer = $VisibleTimer
onready var respawn_timer = $RespawnTimer
onready var hand = $Sprite/Hand
onready var health_bar = $PlayerIndicator/HealthBar
onready var pickup_area = $PickupArea
onready var map_handler = get_node("/root/SceneHandler/MapHandler")
onready var player_container = get_node("/root/SceneHandler/Players")
# Sounds
onready var jump_sound = $Sounds/JumpSound
onready var hurt_sound = $Sounds/HurtSound
onready var footstep_sound_player = $Sounds/FootstepSound
onready var death_sound = $Sounds/DeathSound
onready var respawn_sound = $Sounds/RespawnSound
onready var pickup_sound = $Sounds/PickupSound

# Hold stomp detector shape
onready var stomp_detector_shape = stomp_detector.get_node("CollisionShape2D").get_shape()

# Player spawns reference
var player_spawns_container = null
# HUD reference
var hud = null

# Footstep sound list
var footstep_sounds = [
	preload("res://Assets/SFX/Sounds/footstep_0.wav"),
	preload("res://Assets/SFX/Sounds/footstep_1.wav")
]

const JUMP_HEIGHT = 300
const MAX_FALLSPEED = 400
const GRAVITY = 2

# Force of player against RigidBodies
const PUSH = 100

# Animation names
var stand_jump_transition = "parameters/stand_jump_transition/current"
var idle_move_transition = "parameters/idle_move_transition/current"
var crouch_sneak_transition = "parameters/crouch_sneak_transition/current"
var kick_oneshot = "parameters/kick_oneshot/active"
var kick_anim_seek = "parameters/kick_anim_seek/seek_position"
var hurt_oneshot = "parameters/hurt_oneshot/active"
var hurt_anim_seek = "parameters/hurt_anim_seek/seek_position"

# Smoke particles
var smoke_particles_scene = preload("res://Scenes/Instances/Particles/SmokeParticles/SmokeParticles.tscn")

# Sprite Textures
var sprite_textures = {
	"doux" : preload("res://Assets/Sprites/Player/doux.png"),
	"mort" : preload("res://Assets/Sprites/Player/mort.png"),
	"tard" : preload("res://Assets/Sprites/Player/tard.png"),
	"vita" : preload("res://Assets/Sprites/Player/vita.png")
}

# Icon Textures
var icon_textures = {
	"doux" : preload("res://Assets/Sprites/Player/Icons/icon_doux.png"),
	"mort" : preload("res://Assets/Sprites/Player/Icons/icon_mort.png"),
	"tard" : preload("res://Assets/Sprites/Player/Icons/icon_tard.png"),
	"vita" : preload("res://Assets/Sprites/Player/Icons/icon_vita.png")
}

var death_shake_amount = 200
var hurt_shake_amount = 80

const MIN_STOMP_SPEED = 50

const MAXSPEED = 110
const ACCEL = 6

var is_kicking = false

# Determine if the player is currently dead
var dead = false
const MAX_HEALTH = 3
var health = 3
var score = 0

# Current picked up item reference
var current_item = null

var motion = Vector2.ZERO
export var owner_id = 0
export var sprite_name = "mort"

func _ready():
	pass

# Initialize a player
func init_player(_owner_id, _sprite_index, _player_spawns, _player_hud = null):
	# If we didn't pass player spawns, return false
	if _player_spawns == null:
		return false
	var sprite_count = sprite_textures.size()
	# If the index is not valid
	if _sprite_index < 0 or _sprite_index > sprite_count - 1:
		return false
	
	# HUD reference
	if _player_hud != null:
		hud = _player_hud
		
		# Gets all keys
		var icon_keys = icon_textures.keys()
		# Get key from the icon we want to set
		var icon_to_set_key = icon_keys[_sprite_index]
		# Get the icon
		var icon_to_set = icon_textures[icon_to_set_key]
		
		# Finally, initialize the hud
		hud.init_hud("P" + str(_owner_id + 1), icon_to_set, health)
	
	# Set player spawn reference
	player_spawns_container = _player_spawns
	# Get a random spawn for the player
	var new_spawn = map_handler.get_random_spawn()
	if new_spawn != null:
		position = new_spawn
	
	var sprite_keys = sprite_textures.keys()
	sprite_name = sprite_keys[_sprite_index]
		
	owner_id = _owner_id
	player_label.text = "P" + str(owner_id + 1)
	sprite.texture = sprite_textures[sprite_name]
	return true

func _physics_process(delta):
	
	if not dead:
		_manage_gravity()
		_manage_movement_inputs()
		_manage_combat_inputs()
		_manage_movement()
		_manage_rigidbody_interactions()
		_manage_interactions()
	_manage_animations()

func update_health_bar():
	health_bar.update_empty(health)

func jump(height):
	motion.y = -height

func get_stomped_on(stomper):
	# Remove health
	set_health(health - 3, stomper)
	
	# Set Y velocity
	motion.y = 0
	
	if not dead:
		# Camera shake
		Globals.shake_camera(hurt_shake_amount)

func get_health():
	return health

func die(killer):
	# Disable stomp detector
	stomp_detector.shape_owner_clear_shapes(0)
	
	if killer != null:
		# Check if we didn't die by ourself
		if killer != self:
			if killer.is_in_group("Player"):
				# Increment the other player's score
				killer.increment_score()
				
	# Drop item if existing
	drop_pickup_item()
	# Play death sound
	death_sound.play()
	# Disable player indicator
	player_indicator.visible = false
	# Play hurt anim
	animation_tree.set(hurt_anim_seek, -1)
	animation_tree.set(hurt_oneshot, true)
	# Switch alive state
	dead = true
	# Disable collision shape
	collision_shape.set_deferred("disabled", true)
	# Start visible timer
	visible_timer.start()
	# Start respawn timer
	respawn_timer.start()
	
	# Camera shake
	Globals.shake_camera(death_shake_amount)

func respawn():
	# Reset player health
	set_health(MAX_HEALTH, self)
	# Enable stomp detector
	stomp_detector.shape_owner_add_shape(0, stomp_detector_shape)
	# Set player to a random spawn location
	var new_spawn = map_handler.get_random_spawn()
	if new_spawn != null:
		position = new_spawn
	# Set to (0, 0) if there was an error
	else:
		position = Vector2(0, 0)
	
	# Show player indicator
	player_indicator.visible = true
	# Enable collision shape
	collision_shape.set_deferred("disabled", false)
	# Show back player
	visible = true
	# Switch alive state
	dead = false
	
	# Play sound
	respawn_sound.play()

func is_dead():
	return dead

func _on_VisibleTimer_timeout():
	visible = false
	# Spawn smoke particles
	spawn_smoke_particles()

func _on_RespawnTimer_timeout():
	respawn()

func spawn_smoke_particles():
	var particles = smoke_particles_scene.instance()
	particles.position = position
	map_handler.add_node(particles)

func vanish():
	# Spawn particles
	spawn_smoke_particles()
	# Drop item if existing
	drop_pickup_item()
	# Remove from player container
	player_container.remove_child(self)
	# Get game camera
	var game_camera = map_handler.get_game_camera()
	if game_camera != null:
		# Refresh player container on the camera
		game_camera.refresh_player_container()

func set_health(new_value, setter):
	# If we lost health
	if new_value > 0 and new_value < health:
		hurt_sound.play()
		# Play health bar hurt anim
		# health_bar.play_hurt_anim()
	
	health = new_value
	# Update displayed health bar and HUD
	update_health_bar()
	refresh_hud()
	if health <= 0:
		die(setter)

func increment_score():
	score += 1
	if hud != null:
		hud.update_score(score)

# Update the hud
func refresh_hud():
	if hud != null:
		hud.update_health(health)
		hud.update_score(score)

func drop_pickup_item():
	if current_item != null:
		
		# Get current item data
		var current_item_data = current_item.get_item_data()
		# If there is a pickup item scene for the weapon to drop
		if Items.ALL_ITEMS_PICKUP.has(current_item_data["name"]):
			# Get item pickup scene
			var item_to_spawn = Items.ALL_ITEMS_PICKUP[current_item_data["name"]].instance()
			# Set its position relative to the player
			item_to_spawn.global_position = global_position
			
			# If the current weapon is a range weapon
			if current_item is RangeWeapon:
				# Set its new item ammo
				item_to_spawn.ammo_in_mag = current_item.ammo_in_mag
				
			# Spawn in game world
			var items_container = map_handler.get_items_container()
			if items_container != null:
				items_container.call_deferred("add_child", item_to_spawn)
		
		# Play pickup sound
		pickup_sound.play()
		
		# Delete weapon of head
		hand.remove_child(current_item)
		
		# Remove reference
		current_item = null

func pick_item_up():
	if current_item != null:
		drop_pickup_item()
	
	# Get all colliding bodies with the area
	var bodies = pickup_area.get_overlapping_bodies()
	# Loop through every element
	for b in bodies:
		# If we can pickup the item
		if b is ItemPickup:
			# Read weapon data
			var item_data = b.get_item_pickup_data()
			# Check if the weapon exists in the dictionary
			if Items.ALL_ITEMS.has(item_data["name"]):
				# Create instance of the item
				var new_item = Items.ALL_ITEMS[item_data["name"]].instance()
				# Initialize it
				new_item.owner_player = self
				new_item.position = new_item.equip_pos
				
				# If the item is a range weapon
				if new_item is RangeWeapon:
					# Set its ammo
					new_item.ammo_in_mag = item_data["ammo_in_mag"]
				
				# Delete pickup of game world
				var items_container = map_handler.get_items_container()
				if items_container != null:
					items_container.remove_child(b)
				else:
					b.queue_free()
				
				# Play pickup sound
				pickup_sound.play()
				
				# Add as a child of the player's hand
				hand.add_child(new_item)
				
				if new_item is HitscanWeapon:
					# Add raycast exception to the owner player
					new_item.add_raycast_exception(self)
				
				# Set current item reference
				current_item = new_item
				
				# Exit the function
				return

func get_x_scale():
	return sprite.scale.x

# Play a random footstep sound
func play_footstep_sound():
	footstep_sound_player.stream = footstep_sounds[randi() % footstep_sounds.size()]
	footstep_sound_player.play()

func play_kick_anim():
	if not is_kicking:
		animation_tree.set(kick_anim_seek, -1)
		animation_tree.set(kick_oneshot, true)

func stop_kicking():
	animation_tree.set(kick_oneshot, false)

func is_kicking():
	return animation_tree.get(kick_oneshot)

func _manage_gravity():
	motion.y = motion.y + GRAVITY
	if motion.y > MAX_FALLSPEED:
		motion.y = MAX_FALLSPEED
func _manage_movement_inputs():
	if Input.is_action_just_pressed("jump_" + str(owner_id)):
		if is_on_floor() and not is_kicking():
			jump(JUMP_HEIGHT)
			jump_sound.play()
	
	if Input.is_action_pressed("right_" + str(owner_id)) and not Input.is_action_pressed("left_" + str(owner_id)):
		motion.x += ACCEL
		
	elif Input.is_action_pressed("left_" + str(owner_id)) and not Input.is_action_pressed("right_" + str(owner_id)):
		motion.x -= ACCEL
	else:
		motion.x = lerp(motion.x, 0, 0.03)

func _manage_combat_inputs():
	if Input.is_action_just_pressed("kick_" + str(owner_id)):
		play_kick_anim()
	if Input.is_action_pressed("fire_" + str(owner_id)):
		if current_item != null:
			if current_item.has_method("fire"):
				current_item.fire()
		
func _manage_interactions():
	if Input.is_action_just_pressed("pickup_" + str(owner_id)):
		pick_item_up()

func _manage_movement():
	motion.x = clamp(motion.x, -MAXSPEED, MAXSPEED)
		
	motion = move_and_slide(motion, Vector2.UP, false, 4, PI/4, false)
func _manage_rigidbody_interactions():
	# Collisions with rigidbodies
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider is RigidBody2D:
			collision.collider.apply_central_impulse(-collision.normal * PUSH)

func _manage_animations():
	
	if not is_kicking():
		# Sprite flip
		if Input.is_action_pressed("right_" + str(owner_id)) and not Input.is_action_pressed("left_" + str(owner_id)):
			sprite.scale.x = 1
		elif Input.is_action_pressed("left_" + str(owner_id)) and not Input.is_action_pressed("right_" + str(owner_id)):
			sprite.scale.x = -1
	
	# Standing and jumping state animations
	if is_on_floor():
		animation_tree.set(stand_jump_transition, 0)
	else:
		animation_tree.set(stand_jump_transition, 1)
		# Stop kick oneshot
		stop_kicking()
	
	if (Input.is_action_pressed("right_" + str(owner_id)) or Input.is_action_pressed("left_" + str(owner_id))) and not (Input.is_action_pressed("left_" + str(owner_id)) and Input.is_action_pressed("right_" + str(owner_id))):
		# Play the walk animation
		animation_tree.set(idle_move_transition, 1)
		animation_tree.set(crouch_sneak_transition, 1)
	# If we are not pressing any movement key
	else:
		# Play the idle animation
		animation_tree.set(idle_move_transition, 0)
		animation_tree.set(crouch_sneak_transition, 0)

func get_owner_id():
	return owner_id

func get_velocity():
	return motion

func get_jump_height():
	return JUMP_HEIGHT

func _on_StompDetector_body_entered(body):
	# If the collision is with another body
	if body != self:
		# Check if we got stomped by a player
		if body.is_in_group("Player"):
			# If so, check if the Y velocity is high enough
			if body.get_velocity().y + -get_velocity().y >= MIN_STOMP_SPEED:
				# Make other player jump
				body.jump(JUMP_HEIGHT / 2)
				get_stomped_on(body)
