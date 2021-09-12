extends HBoxContainer

var heart_full = preload("res://Assets/Sprites/HUD/full_heart.png")
var heart_empty = preload("res://Assets/Sprites/HUD/empty_heart.png")

func update_health(value):
	update_empty(value)

func update_empty(value):
	for i in get_child_count():
		if value > i:
			get_child(i).texture = heart_full
		else:
			get_child(i).texture = heart_empty
