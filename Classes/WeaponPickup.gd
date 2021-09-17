extends ItemPickup

export (String) var weapon_name = ""
export (int) var ammo_in_mag = 0

func get_weapon_pickup_data():
	return {
		"name": weapon_name,
		"ammo": ammo_in_mag
	}
