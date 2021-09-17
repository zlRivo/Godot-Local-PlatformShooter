extends RigidBody2D
class_name ItemPickup

# Throw sound
onready var throw_sound = AudioStreamPlayer.new()

func _ready():
	# Set throw sound
	throw_sound.stream = preload("res://Assets/SFX/Sounds/throw_object.wav")

func throw_object(direction : Vector2):
	apply_central_impulse(direction)
	# Play sound
	if throw_sound.stream != null:
		throw_sound.play()
