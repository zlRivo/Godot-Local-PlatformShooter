extends AcceptDialog

onready var lineedit = $MarginContainer/GroupContainer/MapNameContainer/LineEdit

func reset_dialog_text():
	lineedit.text = ""

func get_dialog_text():
	return lineedit.text
