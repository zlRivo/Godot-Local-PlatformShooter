extends RigidBody2D

onready var collision_sound = $CollisionSound

# When the box hits something
func handle_collision(body):
	collision_sound.play()

func _on_Box_body_entered(body):
	handle_collision(body)
