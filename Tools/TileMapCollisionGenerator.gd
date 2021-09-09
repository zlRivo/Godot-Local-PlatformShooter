tool
extends TileMap

export (bool) var generate_autotile_collision = false
export (int) var tile_size = 16
export (Vector2) var grid_pos = Vector2(0, 0) * tile_size
export (Vector2) var fill_size = Vector2(0, 0)

func _ready():
	if generate_autotile_collision and Engine.editor_hint:
		_generate_autotile_collision()

func _generate_autotile_collision():
	for x in fill_size.x:
		for y in fill_size.y:
			var shape = ConvexPolygonShape2D.new()
			shape.points = [Vector2.ZERO, Vector2(0, tile_size), Vector2(tile_size, tile_size), Vector2(tile_size, 0)]
			tile_set.tile_add_shape(
				0,
				shape,
				Transform2D(0.0, Vector2(0, 0)),
				false,
				Vector2(x, y) + grid_pos
			)
			
	# Remove the script
	set_script(null)
