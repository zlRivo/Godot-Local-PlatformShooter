extends RigidBody2D

onready var collision_sound = $CollisionSound

var camera_shake_amount = 30

# When the box hits something
func handle_collision(body):
	collision_sound.play()
	
	# Camera shake
	Globals.shake_camera(camera_shake_amount)

func _on_Box_body_entered(body):
	handle_collision(body)
