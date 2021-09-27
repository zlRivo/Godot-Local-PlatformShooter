extends EditorObject

onready var bounce_sound = $BounceSound
onready var animation_player = $AnimationPlayer
export (float) var jump_height = 1.4

var camera_shake_amount = 100

# Contain reference to ourself with the specified type
var body : Area2D

func _init():
	var _self = self
	body = _self

func bounce():
	bounce_sound.play()
	animation_player.play("bounce")
	
	# Camera shake
	Globals.shake_camera(camera_shake_amount)

func _on_JumpSpring_body_entered(_body):
	if _body.is_in_group("Player"):
		bounce()
		_body.jump(_body.get_jump_height() * jump_height)
	elif _body is RigidBody2D:
		bounce()
		_body.apply_impulse(Vector2.ZERO, (Vector2.UP + Vector2(rand_range(-0.2, 0.2), 0)) * jump_height * 500)
