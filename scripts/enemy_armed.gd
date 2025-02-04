extends "res://scripts/enemy.gd"

class_name EnemyArmed

@export var bullet_scene: PackedScene
@export var fire_cooldown: float = 0.6
@export var bullet_speed: float = 4400

var last_fire_time: float = -fire_cooldown

func _ready():
	var navigation_map = get_tree().get_first_node_in_group("tilemap").get_navigation_map()
	NavigationServer2D.agent_set_map(navigation_agent_2d.get_rid(), navigation_map)
	navigation_agent_2d.set_navigation_map(navigation_map)
	current_speed = wandering_speed
	get_node("VisionRayCast2D").enabled = true

func fire():
	# Ensure sufficient cooldown has passed
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time >= last_fire_time + fire_cooldown:
		last_fire_time = current_time

		if bullet_scene:
			var bullet_instance = bullet_scene.instantiate()

			# Position the bullet at the muzzle
			var weapon_muzzle = get_node("WeaponSprite/PlayerMuzzle")
			bullet_instance.global_position = weapon_muzzle.global_position

					# Use the WeaponMuzzle's rotation to calculate the direction
			var direction = Vector2.RIGHT.rotated(weapon_muzzle.global_rotation)

			# Align the bullet's velocity and rotation with the muzzle
			bullet_instance.linear_velocity = direction * bullet_speed
			bullet_instance.rotation = weapon_muzzle.global_rotation

			# Add the bullet to the scene
			get_tree().get_current_scene().add_child(bullet_instance)
			
			$WeaponSprite.play()
