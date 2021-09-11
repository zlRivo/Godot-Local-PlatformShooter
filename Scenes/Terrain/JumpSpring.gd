extends Area2D

onready var bounce_sound = $BounceSound
onready var animation_player = $AnimationPlayer
export (float) var jump_height = 1.4

func bounce():
	bounce_sound.play()
	animation_player.play("bounce")

func _on_JumpSpring_body_entered(body):
	if body.is_in_group("Player"):
		bounce()
		body.jump(body.get_jump_height() * jump_height)
	elif body is RigidBody2D:
		bounce()
		body.apply_impulse(Vector2.ZERO, (Vector2.UP + Vector2(rand_range(-0.2, 0.2), 0)) * jump_height * 500)
