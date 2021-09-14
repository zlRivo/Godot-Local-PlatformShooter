extends Control

# References
onready var animation_player = $AnimationPlayer
onready var name_label = $PlayerIndicator/PlayerLabel
onready var sprite = $Sprite
onready var ready_label = $LabelReady
onready var ready_label_animation_player = $LabelReady/AnimationPlayer
onready var player_selector_container = get_parent()
# Arrows animation players
onready var left_arrow_anim_player = $LeftArrow/AnimationPlayer
onready var right_arrow_anim_player = $RightArrow/AnimationPlayer
# Sound
onready var cancel_sound = $CancelSound
onready var confirm_sound = $ConfirmSound
# Character selection menu, used later to know if the screen is visible
export (NodePath) var character_selec_menu_path
onready var character_selec_menu = get_node(character_selec_menu_path)
# Main menu reference to call switch menu, etc...
export (NodePath) var main_menu_path
onready var main_menu = get_node(main_menu_path)

# Character selection choices
var character_selection_choices = {
	"doux" : preload("res://Assets/Sprites/Player/doux.png"),
	"mort" : preload("res://Assets/Sprites/Player/mort.png"),
	"tard" : preload("res://Assets/Sprites/Player/tard.png"),
	"vita" : preload("res://Assets/Sprites/Player/vita.png")
}

var current_character_selection_index = -1

export var owner_id = 0

signal ready_state_changed(owner_id)
signal selection_changed(owner_id)

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
				
		# Selection
		# If the player isn't currently ready
		if get_ready_state() == false:
			if event.is_action_pressed("ui_left_" + str(owner_id)):
				switch_character_selection(get_selection_index() - 1)
				# Play sound
				cancel_sound.play()
				# Play anim
				play_left_selection_anim()
			if event.is_action_pressed("ui_right_" + str(owner_id)):
				switch_character_selection(get_selection_index() - 1)
				# Play sound
				cancel_sound.play()
				# Play anim
				play_right_selection_anim()

func _ready():
	# Connect signals to parent container
	connect("selection_changed", player_selector_container, "_on_selection_changed")
	connect("ready_state_changed", player_selector_container, "_on_ready_state_changed")
	
	# Set name to label
	name_label.text = "P" + str(owner_id + 1)
	# Play move anim
	animation_player.play("move")
	# Select default character
	switch_character_selection(1)

func switch_menu(new_menu : Control):
	if main_menu == null:
		return
		
	main_menu.switch_menu(new_menu)
	# If we switch to another menu
	if new_menu != self:
		# Set player ready state to false
		set_ready_state(false)

func switch_character_selection(_new_index) -> bool:
	# If we switch to the same index do nothing
	if _new_index == current_character_selection_index:
		return false
	
	# Get keys to access the dictionary with index
	var choices_keys = character_selection_choices.keys()
	# Get size of array
	var choices_amount = choices_keys.size()
	
	var new_index = _new_index
	# Clamp new selection
	if new_index > choices_amount - 1:
		new_index = 0
	if new_index < 0:
		# Set to last index
		new_index = choices_amount - 1
	
	# Switch texture
	sprite.texture = character_selection_choices[choices_keys[new_index]]
	
	# Set new current selection
	current_character_selection_index = new_index
	# Emit signal
	emit_signal("selection_changed", owner_id)
	
	return true

func get_selection_index():
	return current_character_selection_index

func reset_camera_zoom():
	if main_menu == null:
		return
		
	main_menu.reset_camera_zoom()
	
func play_ui_action_sound():
	if main_menu == null:
		return
		
	main_menu.play_ui_action_sound()

func play_left_selection_anim():
	if left_arrow_anim_player.is_playing():
		left_arrow_anim_player.stop()
	left_arrow_anim_player.play("tick")

func play_right_selection_anim():
	if right_arrow_anim_player.is_playing():
		right_arrow_anim_player.stop()
	right_arrow_anim_player.play("tick")

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
		# Camera shake
		Globals.shake_camera(100, 0.4)
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
	emit_signal("ready_state_changed", owner_id, ready_state)

func set_all_players_ready_state(new_ready_state : bool):
	if player_selector_container == null:
		return
		
	player_selector_container.set_all_players_ready_state(new_ready_state)

func get_owner_id():
	return owner_id

func get_ready_state():
	return ready_state
