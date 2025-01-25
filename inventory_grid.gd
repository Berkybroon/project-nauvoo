extends GridContainer

@export var inventory_manager: Node  # Reference to the inventory manager
@export var slot_texture: Texture  # Default texture for empty slots

func _ready():
	# Connect signals
	inventory_manager.connect("item_added", Callable(self, "_on_item_added"))
	inventory_manager.connect("item_removed", Callable(self, "_on_item_removed"))
	
	# Initialize slots
	for i in range(inventory_manager.max_slots):
		var button = TextureButton.new()
		button.texture_normal = slot_texture
		button.name = str(i)  # Optional: Set a name for debugging
		button.connect("pressed", Callable(self, "_on_slot_pressed").bind(i))
		add_child(button)

# Toggle visibility on player input
func _input(event):
	if event.is_action_pressed("toggle_inventory"):
		visible = !visible

func _on_item_added(item):
	# Update the inventory grid with the new item
	_update_inventory_display()

func _on_item_removed(item):
	# Update the inventory grid when an item is removed
	_update_inventory_display()

func _on_slot_pressed(slot_index):
	# Handle slot click (e.g., equip or use item)
	var item = inventory_manager.inventory[slot_index] if slot_index < inventory_manager.inventory.size() else null
	if item:
		print("Item selected:", item)
	else:
		print("Empty slot selected")

func _update_inventory_display():
	for i in range(get_child_count()):
		var button = get_child(i) as TextureButton
		if i < inventory_manager.inventory.size():
			var item = inventory_manager.inventory[i]
			if item.icon:  # Check if the icon exists
				button.texture_normal = item.icon
			else:
				button.texture_normal = slot_texture  # Fallback to default texture
		else:
			button.texture_normal = slot_texture  # Empty slot texture
