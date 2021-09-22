extends Area2D

# Store who created the explosion
var explosion_owner = null

onready var animation_player = $AnimationPlayer

var camera_shake = 150

func _ready():
	explode()

func explode():
	# Get all the bodies within the area
	var bodies = get_overlapping_bodies()
	print(bodies)
	# Loop through the bodies
	for b in bodies:
		print(b.name)
		# If it is a player and not the owner
		if b.is_in_group("Player") and explosion_owner != b:
			# Kill the player
			b.die(explosion_owner)
			
	# Play explode animation
	animation_player.play("explosion")
	# Shake camera
	Globals.shake_camera(camera_shake, 0.2)


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"explosion":
			# Delete on animation finish
			queue_free()
