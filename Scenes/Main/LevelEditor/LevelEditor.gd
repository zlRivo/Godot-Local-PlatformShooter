extends Control

# References
onready var button_toggle_items_menu = $GUI/ButtonToggleItemsMenu
onready var item_selection = $GUI/ItemSelection

# When scene gets added to the tree or switched to
func _enter_tree():
	# Show the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

