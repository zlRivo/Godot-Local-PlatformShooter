extends TabContainer

const VISIBLE_Y_POS = 380
const INVISIBLE_Y_POS = 720

onready var target_height = VISIBLE_Y_POS

var enabled = true

# References
onready var terrain_items_container = $Terrain/ScrollContainer/GridContainer
onready var miscellaneous_items_container = $Miscellaneous/ScrollContainer/GridContainer

signal item_clicked(sender)

# Shows the menu
func show_node():
	target_height = VISIBLE_Y_POS
	# Enable the menu
	enabled = true
	# Start moving node
	set_process(true)

# Hides the menu
func hide_node():
	target_height = INVISIBLE_Y_POS
	# Disable the menu
	enabled = false
	# Start moving node
	set_process(true)

func toggle_menu():
	if enabled:
		hide_node()
	if not enabled:
		show_node()

func _ready():
	connect_item_signals()

# Connect all the contained items signals to this node
func connect_item_signals():
	# Get all the editor items
	var items_to_connect = terrain_items_container.get_children()
	for c in miscellaneous_items_container.get_children():
		items_to_connect.append(c)
		
	# Connect all the signals
	for item in items_to_connect:
		item.connect("item_clicked", self, "_on_item_clicked")
		
func _on_item_clicked(sender):
	emit_signal("item_clicked", sender)

func _process(delta):
	rect_global_position.y = lerp(rect_global_position.y, target_height, 0.6 * delta)
	
	# Stop process if animation finished
	if rect_global_position.y == target_height:
		set_process(false)
