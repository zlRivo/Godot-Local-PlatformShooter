extends ItemPickup

export (int) var ammo_in_mag = 0

# For connecting fadeout animation
export (NodePath) var sprite_path
onready var sprite = get_node_or_null(sprite_path)

# Time before the gun starts fading out
var disappear_time = 2
var elapsed_time = 0

# Fade out animation player
var fade_out_anim_player = null

# Know if the fire cooldown is finished
var fire_cooldown_timer_finished = true

func _ready():
	set_process(false)
	# Create animation player
	create_animation_player()
	# Create animation
	create_fade_out_animation()

# Generate a fade out animation with the sprite path provided
func create_fade_out_animation():
	# If we provided a sprite path and there is an existing animation player
	if sprite != null and fade_out_anim_player != null:
		# Create new animation
		var fade_out_anim = Animation.new()
		# Add fade-out animation to animation player
		fade_out_anim_player.add_animation("fadeout", fade_out_anim)
		# Add track to animation
		fade_out_anim.add_track(0)
		# Change animation interpolation
		fade_out_anim.track_set_interpolation_type(0, Animation.INTERPOLATION_LINEAR)
		# Set what the track will animate
		fade_out_anim.track_set_path(0, str(sprite_path) + ":modulate")
		# Insert keyframes
		fade_out_anim.track_insert_key(0, 0.0, sprite.modulate) # Full color
		fade_out_anim.track_insert_key(0, 1.0, Color(sprite.modulate.r, sprite.modulate.g, sprite.modulate.b, 0)) # Invisible
	
func create_animation_player():
	# Create animation player
	fade_out_anim_player = AnimationPlayer.new()
	# Add to scene as child of weapon pickup
	add_child(fade_out_anim_player)
	# Connect signals
	fade_out_anim_player.connect("animation_finished", self, "_on_animation_finished")

func _on_animation_finished(anim_name):
	match anim_name:
		"fadeout":
			delete_item()
			
# When added to tree
func _enter_tree():
	# If there is no ammo in the gun
	if ammo_in_mag <= 0:
		# Start weapon disappear
		call_deferred("set_process", true)

# Disappear time counter
func _process(delta):
	elapsed_time += delta
	if elapsed_time >= disappear_time:
		# Start fade out animation if it exists else delete the node
		if fade_out_anim_player.has_animation("fadeout"):
			fade_out_anim_player.play("fadeout")
		else:
			delete_item()
		
		# Reset time (not really needed in theory)
		elapsed_time = 0
		
		# Stop counting time
		set_process(false)

func get_item_pickup_data():
	return {
		"name": item_name,
		"ammo_in_mag": ammo_in_mag,
		"fire_cooldown_timer_finished": fire_cooldown_timer_finished
	}
