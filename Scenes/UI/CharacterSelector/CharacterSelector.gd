extends Control

# References
onready var animation_player = $AnimationPlayer
onready var name_label = $PlayerIndicator/PlayerLabel
onready var ready_label = $LabelReady
onready var ready_label_animation_player = $LabelReady/AnimationPlayer
onready var player_selector_container = get_parent()
# Sound
onready var cancel_sound = $CancelSound
onready var confirm_sound = $ConfirmSound
# Character selection menu, used later to know if the screen is visible
export (NodePath) var character_selec_menu_path
onready var character_selec_menu = get_node(character_selec_menu_path)
# Main menu reference to call switch menu, etc...
export (NodePath) var main_menu_path
onready var main_menu = get_node(main_menu_path)

export var owner_id = 0

signal ready_state_changed(owner_id)

# Text for ready states
var ready_text = "ready!"
onready var not_ready_text = ready_label.text
var ready_state = false

func _input(event):
	# If the menu is visible
	if character_selec_menu != null and character_selec_menu.visible:
		if event.is_action_pressed("ui_accept_" + str(owner_id)):
			set_ready_state(!ready_state)
		
		if event.is_action_pressed("ui_cancel_" + str(owner_id)):
			if get_ready_state() == false:
				if main_menu != null:
					# Play UI Sound
					play_ui_action_sound()
					# Go to main menu
					switch_menu(main_menu.get_main_menu_node())
					# Switch ready state to false for all players
					set_all_players_ready_state(false)
					# Reset camera zoom
					reset_camera_zoom()
			else:
				# Set player to not ready
				set_ready_state(false)

func _ready():
	name_label.text = "P" + str(owner_id + 1)
	animation_player.play("move")

func switch_menu(new_menu : Control):
	if main_menu == null:
		return
		
	main_menu.switch_menu(new_menu)
	# If we switch to another menu
	if new_menu != self:
		# Set player ready state to false
		set_ready_state(false)

func reset_camera_zoom():
	if main_menu == null:
		return
		
	main_menu.reset_camera_zoom()
	
func play_ui_action_sound():
	if main_menu == null:
		return
		
	main_menu.play_ui_action_sound()

func set_ready_state(new_ready_state : bool):
	# If we change it to the same state, exit func
	if new_ready_state == ready_state:
		return
	
	# If ready
	if new_ready_state:
		# Change ready label
		ready_label.text = ready_text
		ready_label.modulate = Color(0, 255, 0, 255)
		# Play sound
		confirm_sound.play()
	# If not
	if not new_ready_state:
		# Change ready label
		ready_label.text = not_ready_text
		ready_label.modulate = Color(255, 0, 0, 255)
		# Play sound
		cancel_sound.play()
	
	# Play anim
	if ready_label_animation_player.is_playing():
		ready_label_animation_player.stop()
	ready_label_animation_player.play("highlighting")
	
	# Change ready state
	ready_state = new_ready_state
	# Send signal
	emit_signal("ready_state_changed", owner_id)
	
	print(ready_state)

func set_all_players_ready_state(new_ready_state : bool):
	if player_selector_container == null:
		return
		
	player_selector_container.set_all_players_ready_state(new_ready_state)

func get_ready_state():
	return ready_state
