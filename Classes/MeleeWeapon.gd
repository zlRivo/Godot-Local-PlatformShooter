extends Weapon

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

func attack():
	# Start attack cooldown if not active
	if attack_timer.wait_time <= 0:
		# Attack players
		
		# Start cooldown
		attack_timer.start()
		attack_timer_finished = false

func _on_attack_cooldown_finished():
	attack_timer_finished = true
