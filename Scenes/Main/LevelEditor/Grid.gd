extends Node2D
export var enabled = true
export var grid_increment = 18
# Number of iteration for full grid color
export var sub_grid_count = 8

export (NodePath) var editor_camera_path
onready var editor_camera = get_node_or_null(editor_camera_path)

func _draw():
	if editor_camera != null and enabled:
		var size = get_viewport_rect().size  * editor_camera.zoom / 2
		var cam = editor_camera.position
		for i in range(int((cam.x - size.x) / grid_increment) - 1, int((size.x + cam.x) / grid_increment) + 1):
			var draw_color = "FFFFFF" if (i * grid_increment) % int(grid_increment * sub_grid_count) == 0 else "7F7F7F"
			draw_line(Vector2(i * grid_increment, cam.y + size.y + 100), Vector2(i * grid_increment, cam.y - size.y - 100), draw_color)
		
		for i in range(int((cam.y - size.y) / grid_increment) - 1, int((size.y + cam.y) / grid_increment) + 1):
			var draw_color = "FFFFFF" if (i * grid_increment) % int(grid_increment * sub_grid_count) == 0 else "7F7F7F"
			draw_line(Vector2(cam.x + size.x + 100, i * grid_increment), Vector2(cam.x - size.x - 100, i * grid_increment), draw_color)

func set_state(_new_state):
	enabled = _new_state

func _process(delta):
	# Will call the _draw function
	update()
