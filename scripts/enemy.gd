extends CharacterBody2D

class_name Enemy

@onready var navigation_agent_2d = $NavigationAgent2D
@onready var state_machine = $StateMachine as StateMachine
@onready var vision_ray_cast_2d = $VisionRayCast2D as RayCast2D

@export_group("Loot Table")
@export var healthpack_scene: PackedScene
@export var cigarettes_scene: PackedScene

@export_group("Locomotion")
@export var rotation_speed: float = 2
@export var wandering_speed = 150
@export var navigation_target: CharacterBody2D
@export var chasing_speed = 300

@export_group("Scanning for player")
@export var angle_cone_of_vision = 90
@export var max_vision_distance = 2000
@export var angle_between_rays = 5
@export var scan_interval: float = 0.1 # Seconds between vision scans (results are cached in between)

var current_speed
var health = 100  # Add health for the enemy

var rng = RandomNumberGenerator.new()

var _last_scan_time: float = -1.0
var _last_scan_result: bool = false

func _ready():
	var navigation_map = get_tree().get_first_node_in_group("tilemap").get_navigation_map()
	NavigationServer2D.agent_set_map(navigation_agent_2d.get_rid(), navigation_map)
	navigation_agent_2d.set_navigation_map(navigation_map)
	current_speed = wandering_speed

func move_to_position(target_position: Vector2):
	var motion = global_position.direction_to(target_position) * current_speed
	navigation_agent_2d.set_velocity(motion)
	look_at(target_position)
	velocity = motion
	move_and_slide()

# Unarmed enemies have nothing to fire; EnemyArmed overrides this.
func fire():
	pass

func search_for_player_with_raycast() -> bool:

	# Reuse the last result if we scanned very recently (keeps raycast cost down)
	var now = Time.get_ticks_msec() / 1000.0
	if now - _last_scan_time < scan_interval:
		return _last_scan_result
	_last_scan_time = now
	_last_scan_result = false

	# Error handling for enemy vision variables
	if angle_between_rays <= 0:
		push_error("angle_between_rays must be greater than zero!")
		return false

	# Sweep rays across the cone, centred on the direction the enemy faces (local +X)
	var cast_count = int(angle_cone_of_vision / angle_between_rays) + 1
	var start_angle = -angle_cone_of_vision / 2.0

	for index in cast_count:
		var ray_angle = deg_to_rad(start_angle + angle_between_rays * index)
		vision_ray_cast_2d.target_position = Vector2.RIGHT.rotated(ray_angle) * max_vision_distance
		vision_ray_cast_2d.force_raycast_update()

		# Detected if any of the raycasts hit the player first
		if vision_ray_cast_2d.is_colliding() && vision_ray_cast_2d.get_collider() is Player:
			_last_scan_result = true
			break

	return _last_scan_result

# Called when hit by a bullet
func bullet_impact():
	take_damage(25)

# Reduce health and check for death.
func take_damage(damage: int):
	health -= damage
	if health <= 0:
		die()

# Handle enemy death
func die():
	generate_item_drops()
	remove_from_scene()

func generate_item_drops():

	# Initialize array of scenes of generated items.
	var drops = []

	# Generate random number (consider it a 'luck' value).
	var random_number = rng.randi_range(1, 100)

	# Drop health pack (guaranteed for now)
	drops.append(healthpack_scene)

	if random_number > 50:
		drops.append(cigarettes_scene)

	# Iterate through array and spawn all drops (skipping any scene left unassigned).
	for drop in drops:
		if drop == null:
			continue
		var instance = drop.instantiate()
		instance.global_position = global_position
		get_tree().get_current_scene().call_deferred("add_child", instance)

func remove_from_scene():
	queue_free()
