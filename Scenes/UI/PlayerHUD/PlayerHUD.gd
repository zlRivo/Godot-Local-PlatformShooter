extends Control

# References
onready var health_bar = $HealthBar
onready var icon = $Icon
onready var player_name = $PlayerName
onready var hurt_tween = $HurtTween
onready var label_player_score = $PlayerScore
onready var score_increment_label = $ScoreIncrement
onready var score_increment_label_anim_player = $ScoreIncrement/AnimationPlayer

# Store default hud pos for tween
onready var health_bar_default_pos = health_bar.rect_position

var displayed_health = 3
var displayed_score = 0

# Initialize node
func init_hud(new_name, new_icon, starting_health, starting_score = 0):
	displayed_health = starting_health
	displayed_score = starting_score
	update_health(starting_health)
	update_score(starting_score)
	set_player_name(new_name)
	set_player_icon(new_icon)
	
	# Show the hud once initialized
	visible = true

func show_score_increment():
	score_increment_label.visible = true
	
func hide_score_increment():
	score_increment_label.visible = false

func update_score(value : int):
	label_player_score.text = "SCORE: " + str(value)
	
	# Determine score increment to show
	var anim_text = ""
	if value > displayed_score:
		anim_text = "+" + str(value - displayed_score)
	if value < displayed_score:
		anim_text = "-" + str(displayed_score - value)
	
	if anim_text != "":
		score_increment_label.text = anim_text
		# Play animation
		score_increment_label_anim_player.play("score_increment")
	
	# Update displayed score
	displayed_score = value

func update_health(value):
	# Call health bar method
	health_bar.update_health(value)
	
	# Play hurt anim if value is lower than displayed
	if value < displayed_health:
		hurt_tween.interpolate_property(health_bar, "rect_position", health_bar.rect_position + Vector2(-30, 0), health_bar_default_pos, 0.5, Tween.TRANS_BOUNCE)
		hurt_tween.start()
	
	displayed_health = value

func set_player_name(name):
	player_name.text = name

func set_player_icon(new_icon : Texture):
	icon.texture = new_icon
