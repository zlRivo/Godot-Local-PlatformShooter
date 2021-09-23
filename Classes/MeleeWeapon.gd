extends Weapon
class_name MeleeWeapon

export (float) var attack_speed = 0
export (float) var damage = 3

# Weapon hitbox
export (NodePath) var hitbox_path
onready var hitbox = get_node_or_null(hitbox_path)

# Timer used for attack speed
var attack_timer = Timer.new()

# Know if the attack cooldown is finished
var attack_timer_finished = true

func _ready():
	# Initialize timer
	attack_timer.one_shot = true
	attack_timer.wait_time = attack_speed
	# Connect timer signal
	attack_timer.connect("timeout", self, "_on_attack_cooldown_finished")
	# Add to scene
	add_child(attack_timer)

func play_attack_sound():
	if attack_sound != null:
		attack_sound.play()

func fire():
	# Start attack cooldown if not active
	if attack_timer_finished:
		# Play attack animation
		if animation_player != null:
			if animation_player.has_animation("fire"):
				if animation_player.is_playing():
					animation_player.stop()
				animation_player.play("fire")
		
		# Start cooldown
		attack_timer.start()
		attack_timer_finished = false

func _on_attack_cooldown_finished():
	attack_timer_finished = true

func kill_players_within_hitbox():
	# Do nothing if no hitbox
	if hitbox == null:
		return
	
	# Get all the bodies colliding with the hitbox
	var colliding_bodies = hitbox.get_overlapping_bodies()
	for b in colliding_bodies:
		# Go to next iteration if we are colliding with ourself
		if b == owner_player:
			continue
			
		# If the body is a player
		if b.is_in_group("Player"):
			# Apply damage to the player
			b.set_health(b.get_health() - damage, owner_player)
	
