extends Sprite

signal cursor_moved

# Store last position of cursor
onready var last_cursor_position = global_position

func _physics_process(delta):
	if last_cursor_position != global_position:
		emit_signal("cursor_moved")
	last_cursor_position = global_position

func get_last_cursor_position():
	return last_cursor_position
