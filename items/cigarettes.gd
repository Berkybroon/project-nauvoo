extends "res://scripts/item_base.gd"

const item_scene_path = "res://scenes/cigarettes_pickup.tscn"

func on_use(player: Player):
	print("puff puff")

func on_drop(player, main_scene):
	var item_scene = load(item_scene_path).instantiate()
	item_scene.global_position = player.global_position
	main_scene.call_deferred("add_child", item_scene)
