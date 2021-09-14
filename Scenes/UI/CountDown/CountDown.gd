extends Label

# References
onready var interval = $Interval
onready var animation_player = $AnimationPlayer
onready var tick_sound = $TickSound
onready var finish_sound = $FinishSound

var current_time = -1

# Know if the countdown is currently active
var active = false

signal countdown_finished

func _ready():
	# Hide
	visible = false

func start_countdown(seconds : int):
	# Set to visible
	visible = true
	
	# Reset time
	current_time = seconds
	# Update text
	text = str(current_time)
	# Play anim and sound
	play_anim()
	# Start interval timer
	interval.start()
	# Set state to active
	active = true

func stop_countdown():
	if is_active():
		# Hide node
		visible = false
		# Set state to inactive
		active = false
		# Stop timer
		interval.stop()

func _update_countdown():
	# Decrement time
	current_time -= 1
	# Update text
	text = str(current_time)
	
	# If there is still time
	if current_time > 0:
		# Play animation and sound
		play_anim()
	else:
		# Play finish sound
		finish_sound.play()
		# Hide node
		visible = false
		# Stop timer
		interval.stop()
		# Set state to inactive
		active = false
		# Emit signal
		emit_signal("countdown_finished")

# Know if the countdown is currently active
func is_active() -> bool:
	return active

func play_anim():
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("countdown")
	
	# Play sound
	tick_sound.play()
	
# Interval tick
func _on_Interval_timeout():
	_update_countdown()
