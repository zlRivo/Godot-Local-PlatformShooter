extends Area2D

# Store who created the explosion
var explosion_owner = null

onready var animation_player = $AnimationPlayer
onready var explosion_sound = $ExplosionSound
onready var collision_shape = $CollisionShape2D

var camera_shake = 150

var explosion_damage = 0
var rigidbody_force = 250
onready var MAX_DISTANCE = collision_shape.shape.radius

# Contains all the bodies within the area
var body_list = []

func _ready():
	explode()

func explode():
	# Play explode animation
	animation_player.play("explosion")
	# Play sound
	explosion_sound.play()
	# Shake camera
	Globals.shake_camera(camera_shake, 0.2)
	
	# Delay for making sure every body is in the list
	yield(get_tree().create_timer(0.05), "timeout")
	
	# Loop through the bodies
	for b in body_list:
		# Apply force to rigidbodies
		if b is RigidBody2D:
			# Get the vector between the explosion and the target
			var direction_vector = (b.global_position - global_position).normalized()
			# Know the distance between the explosion and the body
			var distance = global_position.distance_to(b.global_position)
			# If the body center is in the area
			if distance < MAX_DISTANCE:
				var multiplier = max(1, MAX_DISTANCE - distance) # Prevent division by zero
				# Add force to the rigidbody
				b.apply_central_impulse(direction_vector * rigidbody_force * (MAX_DISTANCE / multiplier ))
		
		# If it is a player and not the owner
		if b.is_in_group("Player") and explosion_owner != b:
			# Kill the player
			b.set_health(b.get_health() - explosion_damage, explosion_owner)
			continue

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"explosion":
			# Delete on animation finish
			queue_free()

func _on_SQLDeleteExplosion_body_entered(body):
	body_list.append(body)

func _on_SQLDeleteExplosion_body_exited(body):
	body_list.erase(body)
