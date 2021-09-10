extends KinematicBody2D

# References
onready var sprite = $Sprite
onready var animation_tree = $AnimationTree
onready var player_label = $PlayerIndicator/PlayerLabel

const JUMP_HEIGHT = 300
const MAX_FALLSPEED = 400
const GRAVITY = 2

# Animation names
var stand_jump_transition = "parameters/stand_jump_transition/current"
var idle_move_transition = "parameters/idle_move_transition/current"
var crouch_sneak_transition = "parameters/crouch_sneak_transition/current"
var kick_oneshot = "parameters/kick_oneshot/active"
var kick_anim_seek = "parameters/kick_anim_seek/seek_position"
var hurt_oneshot = "parameters/hurt_oneshot/active"
var hurt_anim_seek = "parameters/hurt_anim_seek/seek_position"

# Sprite Textures
var sprite_textures = {
	"doux" : preload("res://Assets/Sprites/Player/doux.png"),
	"mort" : preload("res://Assets/Sprites/Player/mort.png"),
	"tard" : preload("res://Assets/Sprites/Player/tard.png"),
	"vita" : preload("res://Assets/Sprites/Player/vita.png")
}

const MAXSPEED = 160
const ACCEL = 6

var is_kicking = false

var motion = Vector2.ZERO
export var owner_id = 0
export var sprite_name = "mort"

func _ready():
	init_player(owner_id, sprite_name)

# Initialize a player
func init_player(_owner_id, _sprite_name):
	if sprite_textures[_sprite_name] == null:
		return false
	sprite_name = _sprite_name
		
	owner_id = _owner_id
	player_label.text = "P" + str(owner_id + 1)
	sprite.texture = sprite_textures[sprite_name]
	return true

func _physics_process(delta):
	
	_manage_gravity()
	_manage_movement_inputs()
	_manage_combat_inputs()
	_manage_movement()
	_manage_animations()

func play_hurt_anim():
	animation_tree.set(hurt_anim_seek, -1)
	animation_tree.set(hurt_oneshot, true)

func play_kick_anim():
	if not is_kicking:
		animation_tree.set(kick_anim_seek, -1)
		animation_tree.set(kick_oneshot, true)

func stop_kicking():
	animation_tree.set(kick_oneshot, false)
func is_kicking():
	return animation_tree.get(kick_oneshot)

func _manage_gravity():
	motion.y = motion.y + GRAVITY
	if motion.y > MAX_FALLSPEED:
		motion.y = MAX_FALLSPEED
func _manage_movement_inputs():
	if Input.is_action_just_pressed("jump_" + str(owner_id)):
		if is_on_floor() and not is_kicking():
			motion.y = -JUMP_HEIGHT
	
	if Input.is_action_pressed("right_" + str(owner_id)) and not Input.is_action_pressed("left_" + str(owner_id)):
		motion.x += ACCEL
		
	elif Input.is_action_pressed("left_" + str(owner_id)) and not Input.is_action_pressed("right_" + str(owner_id)):
		motion.x -= ACCEL
	else:
		motion.x = lerp(motion.x, 0, 0.03)
func _manage_combat_inputs():
	if Input.is_action_just_pressed("kick_" + str(owner_id)):
		play_kick_anim()
func _manage_movement():
	motion.x = clamp(motion.x, -MAXSPEED, MAXSPEED)
		
	motion = move_and_slide(motion, Vector2.UP)
func _manage_animations():
	
	if not is_kicking():
		# Sprite flip
		if Input.is_action_pressed("right_" + str(owner_id)) and not Input.is_action_pressed("left_" + str(owner_id)):
			sprite.scale.x = 1
		elif Input.is_action_pressed("left_" + str(owner_id)) and not Input.is_action_pressed("right_" + str(owner_id)):
			sprite.scale.x = -1
	
	# Standing and jumping state animations
	if is_on_floor():
		animation_tree.set(stand_jump_transition, 0)
	else:
		animation_tree.set(stand_jump_transition, 1)
		# Stop kick oneshot
		stop_kicking()
	
	if (Input.is_action_pressed("right_" + str(owner_id)) or Input.is_action_pressed("left_" + str(owner_id))) and not (Input.is_action_pressed("left_" + str(owner_id)) and Input.is_action_pressed("right_" + str(owner_id))):
		# Play the walk animation
		animation_tree.set(idle_move_transition, 1)
		animation_tree.set(crouch_sneak_transition, 1)
	# If we are not pressing any movement key
	else:
		# Play the idle animation
		animation_tree.set(idle_move_transition, 0)
		animation_tree.set(crouch_sneak_transition, 0)
