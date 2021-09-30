class_name ScenePacker

static func pack_node(_node : Node) -> PackedScene:
	set_owner(_node, _node)
	var package = PackedScene.new()
	package.pack(_node)
	return package
	
static func set_owner(_node : Node, _owner : Node) -> void:
	for child in _node.get_children():
		child.owner = _owner
		# If the node is a scene 
		if child.get_filename() != "":
			# Set to child of the scene
			set_owner(child, child)
		else:
			# Set to child of the defined node
			set_owner(child, _owner)
