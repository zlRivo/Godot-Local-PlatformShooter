extends Control

# References
onready var animation_player = $AnimationPlayer
onready var name_label = $PlayerIndicator/PlayerLabel
onready var ready_label = $LabelReady
onready var ready_label_animation_player = $LabelReady/AnimationPlayer

export var owner_id = 0

signal ready_state_changed(owner_id)

# Text for ready states
var ready_text = "ready!"
onready var not_ready_text = ready_label
var ready_state = false

func _ready():
	name_label.text = "P" + str(owner_id + 1)
	animation_player.play("move")

func set_ready_state(new_ready_state : bool):
	# If we change it to the same state, exit func
	if new_ready_state == ready_state:
		return
	
	# If ready
	if new_ready_state:
		# Change ready label
		ready_label.text = ready_text
		ready_label.modulate = Color(0, 255, 0, 255)
	# If not
	if not new_ready_state:
		# Change ready label
		ready_label.text = ready_text
		ready_label.modulate = Color(255, 0, 0, 255)
	
	# Play anim
	ready_label_animation_player.seek(0)
	ready_label_animation_player.play("highlighting")
	
	# Change ready state
	ready_state = new_ready_state
	# Send signal
	emit_signal("ready_state_changed", owner_id)

func get_ready_state():
	return ready_state
