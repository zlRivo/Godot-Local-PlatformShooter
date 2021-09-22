extends Area2D

# Store who created the explosion
var explosion_owner = null

onready var animation_player = $AnimationPlayer
onready var explosion_sound = $ExplosionSound

var camera_shake = 150

var explosion_damage = 0

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
		# If it is a player and not the owner
		if b.is_in_group("Player") and explosion_owner != b:
			# Kill the player
			b.set_health(b.get_health() - explosion_damage, explosion_owner)

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"explosion":
			# Delete on animation finish
			queue_free()

func _on_SQLDeleteExplosion_body_entered(body):
	body_list.append(body)

func _on_SQLDeleteExplosion_body_exited(body):
	body_list.erase(body)
