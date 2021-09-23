extends Area2D

# Store who created the explosion
var explosion_owner = null

onready var animation_player = $AnimationPlayer
onready var explosion_sound = $ExplosionSound
onready var collision_shape = $CollisionShape2D

var camera_shake = 150

var explosion_damage = 0
var rigidbody_force = 1000
onready var max_vector_size = collision_shape.shape.radius

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
			var distance_vector = ((b.global_position - global_position).normalized() * max_vector_size) - (b.global_position - global_position).normalized()
			# Add force to the rigidbody
			b.apply_central_impulse(distance_vector * rigidbody_force)
		
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
