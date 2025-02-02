extends Node

var player_inventory: Array = []
var player_inventory_slots: int

func set_inventory(items: Array):
	player_inventory = items

func get_inventory() -> Array:
	return player_inventory

func set_max_inventory_slots(max_slots):
	player_inventory_slots = max_slots

func get_max_inventory_slots():
	return player_inventory_slots
