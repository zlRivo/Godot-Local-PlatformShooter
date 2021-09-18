extends KinematicBody2D

# References
onready var trail = $Trail
onready var collision_area = $CollisionArea
onready var mesh = $Bullet

# To prevent detecting collision from the one who instanciated this node
var owner_entity = null

var trail_length = 25
var bullet_speed = 500000
# Lifetime before getting delete from the scene
var lifetime = 0.15
var elapsed_time = 0

var collision_detected = false

# Direction to go with the trail
var direction = Vector2.ZERO

func init_trail(_direction : Vector2, _lifetime : float, _owner_entity = null):
	# Delete if velocity if zero
	if _direction == Vector2.ZERO:
		queue_free()
	direction = _direction
	owner_entity = _owner_entity
	#lifetime = _lifetime

func _physics_process(delta):
	# Delete after lifetime
	elapsed_time += delta
	if elapsed_time >= lifetime:
		queue_free()
	
	# Set trail values
	trail.global_position = Vector2.ZERO
	trail.global_rotation = 0
	
	# If we didn't collide
	if not collision_detected:
		# Move in the provided direction
		move_and_slide(direction.normalized() * delta * bullet_speed)
		#move_and_slide(Vector2(1200, 0))
	
	# Constantly add point to the current position
	trail.add_point(global_position)
	# Delete old points
	while trail.get_point_count() > trail_length:
		# Delete the first point (tail)
		trail.remove_point(0)


func _on_CollisionArea_body_entered(body):
	if body != owner_entity:
		collision_detected = true
		# Hide bullet mesh
		mesh.visible = false
