extends Weapon
class_name RangeWeapon

export (float) var fire_rate = 0
export (float) var damage = 3
export (int) var ammo_in_mag = 0
export (bool) var unlimited_ammo
export (float) var camera_shake = 0

# Timer used for attack speed
var fire_cooldown_timer = Timer.new()

# Know if the firing cooldown is finished
var fire_cooldown_timer_finished = true

# Empty sound
var empty_sound_data = preload("res://Assets/SFX/Sounds/empty.wav")
# Empty sound player
var empty_sound_player = AudioStreamPlayer.new()

func _ready():
	# Initialize timer
	fire_cooldown_timer.one_shot = true
	fire_cooldown_timer.wait_time = fire_rate
	# Connect timer signal
	fire_cooldown_timer.connect("timeout", self, "_on_fire_cooldown_timer_finished")
	# Add to scene
	add_child(fire_cooldown_timer)
	
	# Start fire recover timer if it wasn't finished
	if not fire_cooldown_timer_finished:
		fire_cooldown_timer.start()
		
	# Initialize empty sound player
	empty_sound_player.stream = empty_sound_data
	# Add to scene
	add_child(empty_sound_player)

func start_fire_cooldown():
	# Start cooldown
	fire_cooldown_timer.start()
	fire_cooldown_timer_finished = false

func _on_fire_cooldown_timer_finished():
	fire_cooldown_timer_finished = true
	
func get_item_data():
	return {
		"name": item_name,
		"ammo_in_mag": ammo_in_mag,
		"fire_cooldown_timer_finished": fire_cooldown_timer_finished
	}
