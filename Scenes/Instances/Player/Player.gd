extends KinematicBody2D

# References
onready var sprite = $Sprite

const JUMP_HEIGHT = 300
const MAX_FALLSPEED = 400
const GRAVITY = 2

const MAXSPEED = 160
const ACCEL = 6

var motion = Vector2.ZERO

func _physics_process(delta):
	motion.y = motion.y + GRAVITY
	if motion.y > MAX_FALLSPEED:
		motion.y = MAX_FALLSPEED
	
	if Input.is_action_just_pressed("jump_0"):
		if is_on_floor():
			motion.y = -JUMP_HEIGHT
	
	if Input.is_action_pressed("right_0"):
		motion.x += ACCEL
		sprite.scale.x = 1
	elif Input.is_action_pressed("left_0"):
		motion.x -= ACCEL
		sprite.scale.x = -1
	else:
		motion.x = lerp(motion.x, 0, 0.02)
	
	motion.x = clamp(motion.x, -MAXSPEED, MAXSPEED)
		
	motion = move_and_slide(motion, Vector2.UP)
