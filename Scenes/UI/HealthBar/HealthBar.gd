extends Control

var heart_full = preload("res://Assets/Sprites/HUD/full_heart.png")
var heart_empty = preload("res://Assets/Sprites/HUD/empty_heart.png")
onready var health_container = $HeartContainer
onready var animation_player = $AnimationPlayer

func update_health(value):
	update_empty(value)

func update_empty(value):
	for i in health_container.get_child_count():
		if value > i:
			health_container.get_child(i).texture = heart_full
		else:
			health_container.get_child(i).texture = heart_empty

func play_hurt_anim():
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("hurt")
