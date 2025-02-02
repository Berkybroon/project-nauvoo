extends GridContainer

@export var slot_texture: Texture  # Default texture for empty slots

var inventory_slots: int = global.get_max_inventory_slots()
var inventory: Array = global.get_inventory()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for item in range(inventory_slots):
		var button = TextureButton.new()
		button.texture_normal = slot_texture
		add_child(button)
		
		_update_inventory_display()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _update_inventory_display():
	for i in range(get_child_count()):
		var button = get_child(i) as TextureButton

		if i < inventory.size():
			var item = inventory[i]
			if item.icon:
				button.texture_normal = item.icon
			else:
				button.texture_normal = slot_texture  # Fallback to default texture
		else:
			button.texture_normal = slot_texture  # Empty slot texture
