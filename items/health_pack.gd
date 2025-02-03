extends "res://scripts/item_base.gd"

var item_scene_path = "res://scenes/health_pickup.tscn"

func on_use(player: Player):
	if player.health < 100:
		player.health += 25
		print("Used health pack! Player health:", player.health)
	else:
		print("Player's health is already full!")

func on_drop(player, main_scene):
	var item_scene = load(item_scene_path).instantiate()
	item_scene.global_position = player.global_position
	main_scene.call_deferred("add_child", item_scene)
