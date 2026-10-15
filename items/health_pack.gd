extends "res://scripts/item_base.gd"

var item_scene_path = "res://scenes/health_pickup.tscn"

func on_use(player: Player) -> bool:
	if player.health < player.max_health:
		player.heal(25)
		return true
	return false # Already at full health: keep the pack

func on_drop(player, main_scene):
	var item_scene = load(item_scene_path).instantiate()
	item_scene.global_position = player.global_position
	main_scene.call_deferred("add_child", item_scene)
