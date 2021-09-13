extends Control

# References
onready var label = $Label
onready var animation_player = $AnimationPlayer

func play_highlight_anim():
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("highlighting")
