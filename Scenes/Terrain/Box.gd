extends EditorObject

onready var collision_sound = $CollisionSound

var camera_shake_amount = 2

# Contain reference to ourself with the specified type
var body : RigidBody2D

func _init():
	var _self = self
	body = _self

func _ready():
	body.connect("body_entered", self, "_on_Box_body_entered")

# When the box hits something
func handle_collision(body):
	collision_sound.play()
	
	# Camera shake
	Globals.shake_camera(camera_shake_amount, 0.2)

func _on_Box_body_entered(_body):
	handle_collision(_body)
