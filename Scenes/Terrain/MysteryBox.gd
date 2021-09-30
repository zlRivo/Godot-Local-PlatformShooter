extends EditorObject

var spawn_effect_scene = preload("res://Scenes/Instances/Particles/SmokeParticles/SmokeParticles.tscn")

var enabled = true

var sprite_enabled_coord = 9
var sprite_disabled_coord = 29

var min_hit_velocity = -10

export (bool) var can_recover = true
export (float) var recover_time = 5
var elapsed_time_since_hit = 0

# References
var map_handler = null
onready var spawn_location = $SpawnLocation
onready var sprite = $CollisionShape2D/Sprite
onready var animation_player = $AnimationPlayer
onready var hit_detector = $HitDetector
# Sounds
onready var hit_sound = $Sounds/HitSound
onready var recover_sound = $Sounds/RecoverSound

# Contain reference to ourself with the specified type
var body : StaticBody2D

func _init():
	var _self = self
	body = _self

func _ready():
	if Globals.get_in_editor_state():
		map_handler = get_node("/root/LevelEditor/MapHolder")
	else:
		map_handler = get_node("/root/SceneHandler/MapHandler")
	
	hit_detector.connect("body_entered", self, "_on_HitDetector_body_entered")
	
	# Don't recover at start
	set_process(false)

func _process(delta):
	elapsed_time_since_hit += delta
	# Recover time
	if elapsed_time_since_hit >= recover_time:
		# Re-enable box
		recover_box()
		# Reset time
		elapsed_time_since_hit = 0
		# Stop process
		set_process(false)

func recover_box():
	# Play recover sound
	recover_sound.play()
	# Switch enabled state to true
	set_state(true)

func _on_HitDetector_body_entered(_body):
	# If the box is not enabled, do nothing
	if not enabled:
		return
	
	# If the _body is a player
	if _body.is_in_group("Player"):
		# Get player y velocity
		var player_velocity = _body.get_velocity().y
		# If the player has a high enough velocity
		if player_velocity < min_hit_velocity:
			# Get a random item
			var random_item = Items.get_random_pickup_item()
			# Set its position to the spawn location
			random_item.global_position = spawn_location.global_position
			# Get items container
			var item_container = map_handler.get_items_container()
			if item_container != null:
				# Spawn the item in the scene
				item_container.call_deferred("add_child", random_item)
				# Get decal container
				var decal_container = map_handler.get_decal_container()
				if decal_container != null:
					# Particles effect
					var particles = spawn_effect_scene.instance()
					# Set particles position
					particles.global_position = spawn_location.global_position
					# Add to scene
					decal_container.add_child(particles)
					
				# Play hit animation
				play_hit_anim()
				# Play hit sound
				hit_sound.play()
				
				# Set mystery state
				set_state(false)
				
				# Start recovering if it can
				if can_recover:
					set_process(true)

func play_hit_anim():
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("hit")

func set_state(_new_state):
	if _new_state:
		# Change sprite
		sprite.frame = sprite_enabled_coord
		# Disable the box
		enabled = true
	else:
		# Change sprite
		sprite.frame = sprite_disabled_coord
		# Disable the box
		enabled = false
