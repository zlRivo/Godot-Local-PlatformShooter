extends Control

# References
onready var file_menu_button = $GUI/ColorRect/HBoxContainer/MenuButtonFile

onready var button_toggle_items_menu = $GUI/ButtonToggleItemsMenu
onready var item_selection = $GUI/ItemSelection

func _ready():
	# Connect signals
	file_menu_button.get_popup().connect("id_pressed", self, "_on_file_id_pressed")
	# Set to windowed
	OS.set_window_fullscreen(false)

# When scene gets added to the tree or switched to
func _enter_tree():
	# Show the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_ButtonToggleItemsMenu_pressed():
	item_selection.toggle_menu()

func _on_file_id_pressed(id):
	var text = file_menu_button.get_popup().get_item_text(id)
	match text:
		"Quit":
			get_tree().quit()
		"Return to game":
			get_tree().change_scene("res://Scenes/Main/SceneHandler/SceneHandler.tscn")
	
