extends Node

# Holds all the weapons scenes
const ALL_ITEMS = {
	"M1911": preload("res://Scenes/Instances/Weapons/M1911/M1911.tscn"),
	"PPSH-41": preload("res://Scenes/Instances/Weapons/PPSH-41/PPSH-41.tscn"),
	"SQLCanon": preload("res://Scenes/Instances/Weapons/SQLCanon/SQLCanon.tscn")
}

# Holds all the weapons pickups scenes
const ALL_ITEMS_PICKUP = {
	"M1911": preload("res://Scenes/Instances/Weapons/M1911/M1911Pickup.tscn"),
	"PPSH-41": preload("res://Scenes/Instances/Weapons/PPSH-41/PPSH-41Pickup.tscn"),
	"SQLCanon": preload("res://Scenes/Instances/Weapons/SQLCanon/SQLCanonPickup.tscn")
}

func get_random_pickup_item():
	# Get the keys of the pickup items
	var item_keys = ALL_ITEMS_PICKUP.keys()
	# Randomize for better random
	randomize()
	# Get a random key
	var random_element = item_keys[randi() % item_keys.size()]
	# Return it
	return ALL_ITEMS_PICKUP[random_element].instance()
