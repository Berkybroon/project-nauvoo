extends Node

# Inventory data
var inventory = []
@export var max_slots = 20  # Total slots in the inventory

signal item_added(item)
signal item_removed(item)

# Add an item to the inventory
func add_item(item):
	if inventory.size() < max_slots:
		inventory.append(item)
		emit_signal("item_added", item)
		return true
	else:
		return false  # Inventory full

# Remove an item from the inventory
func remove_item(item):
	if item in inventory:
		inventory.erase(item)
		emit_signal("item_removed", item)

# Get all items
func get_items():
	return inventory
