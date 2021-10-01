extends HBoxContainer

onready var animation_player = $AnimationPlayer

func play_save_anim():
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("fade_out")
