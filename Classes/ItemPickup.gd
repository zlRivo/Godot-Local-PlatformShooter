extends RigidBody2D
class_name ItemPickup

export (String) var item_name = ""

func throw_object(direction : Vector2):
	apply_central_impulse(direction)

func get_item_pickup_data():
	return {
		"name": item_name
	}
