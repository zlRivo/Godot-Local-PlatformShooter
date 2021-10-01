class_name MapSaver

static func save_map(_map_name : String, _map_to_save : PackedScene):
	if _map_to_save == null:
		return false
		
	var dir = Directory.new()
	# If the directory doesn't exist
	if dir.open(Globals.MAP_FOLDER_PATH) != OK:
		# Create a new map directory
		dir.make_dir_recursive(Globals.MAP_FOLDER_PATH)
	
	# Save map
	var error_code = ResourceSaver.save(Globals.MAP_FOLDER_PATH + get_full_map_name(_map_name), _map_to_save)
	if error_code == 0:
		return true
	# Error happend
	return false

# Return the packed scene from the provided path
static func load_map(_map_path):
	var dir = Directory.new()
	# Check if map path exists
	if dir.file_exists(_map_path):
		# Load map
		var map = ResourceLoader.load(_map_path)
		return map
	
	return null

static func get_full_map_name(_map_name):
	return Globals.MAP_PREFIX + _map_name + Globals.MAP_EXTENSION

static func map_exists(_map_name : String):
	var dir = Directory.new()
	var map_path = Globals.MAP_FOLDER_PATH + get_full_map_name(_map_name)
	# Check if the map path exists
	if dir.file_exists(map_path):
		return true
	return false
