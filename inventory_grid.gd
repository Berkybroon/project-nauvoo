extends GridContainer

@export var inventory_manager: Node  # Reference to the inventory manager
@export var slot_texture: Texture  # Default texture for empty slots
@export var popup_menu: PopupMenu  # Popup menu for context actions

var selected_slot_index: int = -1  # Tracks the clicked slot index

func _ready():
	hide()
	
	# Connect signals
	inventory_manager.connect("item_added", Callable(self, "_on_item_added"))
	inventory_manager.connect("item_removed", Callable(self, "_on_item_removed"))
	popup_menu.connect("id_pressed", Callable(self, "_on_popup_menu_action"))

	# Initialize slots
	for i in range(inventory_manager.max_slots):
		var button = TextureButton.new()
		button.texture_normal = slot_texture
		button.connect("pressed", Callable(self, "_on_slot_pressed").bind(i))
		add_child(button)

# Toggle visibility on player input
func _input(event):
	if event.is_action_pressed("toggle_inventory"):
		visible = !visible

func _on_item_added(item):
	_update_inventory_display()

func _on_item_removed(item):
	_update_inventory_display()

func _on_slot_pressed(slot_index):
	# Store the selected slot index
	selected_slot_index = slot_index
	
	# Get item in the slot
	var item = null
	if slot_index < inventory_manager.inventory.size():
		item = inventory_manager.inventory[slot_index]
	
	if item:
		# Show the popup menu at the mouse position
		popup_menu.clear()
		popup_menu.add_item("Use", 0)
		popup_menu.add_item("Drop", 1)
		popup_menu.set_position(get_global_mouse_position())
		popup_menu.popup()
	else:
		print("Empty slot clicked.")

func _on_popup_menu_action(id):
	# Handle popup menu actions
	if id == 0:  # Use
		_use_item(selected_slot_index)
	elif id == 1:  # Drop
		_drop_item(selected_slot_index)

func _use_item(slot_index):
	var item = inventory_manager.inventory[slot_index]
	if item:
		print("Using item:", item.name)
		# Implement your item usage logic here
		# Example: Heal player or apply item effect
		inventory_manager.remove_item(item)  # Optionally remove after use
		_update_inventory_display()

func _drop_item(slot_index):
	var item = inventory_manager.inventory[slot_index]
	if item:
		print("Dropping item:", item.name)
		inventory_manager.remove_item(item)  # Remove from inventory
		_update_inventory_display()

func _update_inventory_display():
	for i in range(get_child_count()):
		var button = get_child(i) as TextureButton
		if not button:
			print("Error: Child at index", i, "is not a TextureButton.")
			continue

		if i < inventory_manager.inventory.size():
			var item = inventory_manager.inventory[i]
			if item.icon:
				button.texture_normal = item.icon
			else:
				button.texture_normal = slot_texture  # Fallback to default texture
		else:
			button.texture_normal = slot_texture  # Empty slot texture
