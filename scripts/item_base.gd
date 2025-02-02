extends Resource
class_name ItemBase

@export var name: String = "Unnamed Item"
@export var description: String = ""
@export var icon: Texture
@export var is_stackable: bool = false
@export var max_stack: int = 1
@export var item_script: Script


# Override these methods in derived item scripts
func on_use(_player):
	print(name, "used! (No behavior defined. Check script is assigned to tres.)")

func on_drop(player, main_scene):
	print(name, "dropped! (No behavior defined. Check script is assigned to tres.)")
