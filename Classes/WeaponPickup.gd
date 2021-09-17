extends ItemPickup

export (int) var ammo_in_mag = 0

func get_item_pickup_data():
	return {
		"name": item_name,
		"ammo_in_mag": ammo_in_mag
	}
