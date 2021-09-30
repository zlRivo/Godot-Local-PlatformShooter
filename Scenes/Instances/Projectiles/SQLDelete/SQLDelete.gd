extends KinematicBody2D

# To prevent detecting collision from the one who instanciated this node
var owner_entity = null

# Map Handler
var map_handler = null

onready var label = $Label
onready var animation_player = $AnimationPlayer
onready var move_sound = $Sound

# Explosion scene
var explosion_scene = preload("res://Scenes/Instances/Projectiles/SQLDelete/SQLDeleteExplosion.tscn")

# X velocity
var projectile_speed = 10000

var damage : float = 0
var explosion_damage = 0

# Direction of the projectile
var direction = Vector2.ZERO

func _ready():
	if Globals.get_in_editor_state():
		map_handler = get_node("/root/LevelEditor/MapHolder")
	else:
		map_handler = get_node("/root/SceneHandler/MapHandler")
	
	# Play spawn animation
	animation_player.play("spawn")

func init_projectile(_direction : Vector2, _damage : float, _explosion_damage : int, _owner_entity = null):
	# Delete if velocity if zero
	if _direction == Vector2.ZERO:
		queue_free()
	direction = _direction.normalized()
	owner_entity = _owner_entity
	explosion_damage = _explosion_damage
	
	# Owner ID text
	var owner_id = -1
	# If the owner of the projectile is a player
	if owner_entity.is_in_group("Player"):
		# Get his owner id
		owner_id = owner_entity.get_owner_id()
		
	# Set the text
	call_deferred("set_text_owner_id", owner_id)
	
	damage = _damage

func set_text_owner_id(_owner_id : int):
	label.text += str(_owner_id)

func _process(delta):
	# Move the projectile
	move_and_slide(direction * projectile_speed * delta)

# Delete the item from the map
func delete_projectile():
	# Create explosion
	var explosion = explosion_scene.instance()
	# Set the position
	explosion.global_position = global_position
	# Set the owner
	explosion.explosion_owner = owner_entity
	# Set explosion damage
	explosion.explosion_damage = explosion_damage
	# Get the projectile container
	var projectile_container = map_handler.get_projectile_container()
	# If we have a container to spawn the projectile in
	if projectile_container != null:
		# Add the explosion
		projectile_container.call_deferred("add_child", explosion)
		
	# Delete the node
	queue_free()

# On collision
func _on_CollisionDetection_body_entered(body):
	# Do nothing if we collided with the owner
	if body == owner_entity:
		return
	
	# If we collided with a player
	if body.is_in_group("Player"):
		# Apply damage to the player
		body.set_health(body.get_health() - damage, owner_entity)
		
	# Delete the projectile
	delete_projectile()


func _on_ShakeTimer_timeout():
	# Shake camera
	Globals.shake_camera(30, 0.1)
	# Play move sound
	move_sound.play()
