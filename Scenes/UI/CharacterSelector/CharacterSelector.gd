extends Control

onready var animation_player = $Sprite/AnimationPlayer
onready var name_label = $PlayerIndicator/PlayerLabel

export var owner_id = 0

func _ready():
	name_label.text = "P" + str(owner_id + 1)
	animation_player.play("move")
