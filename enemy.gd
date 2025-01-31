extends CharacterBody2D

class_name enemy

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

var current_speed
var health = 100  # Add health for the enemy

var rng = RandomNumberGenerator.new()

func _ready():
	var navigation_map = get_tree().get_first_node_in_group("tilemap").get_navigation_map()
	NavigationServer2D.agent_set_map(navigation_agent_2d.get_rid(), navigation_map)
	navigation_agent_2d.set_navigation_map(navigation_map)
	current_speed = wandering_speed

func _process(delta):
	pass

func move_to_position(target_position: Vector2):
	var motion = position.direction_to(target_position) * current_speed
	navigation_agent_2d.set_velocity(motion)
	look_at(target_position)
	rotation -= deg_to_rad(180) # Corrects the enemy sprite walking backwards
	velocity = motion
	move_and_slide()

func search_for_player_with_raycast() -> bool:
	
	# Error handling for enemy vision variables
	if angle_between_rays == 0:
		push_error("angle_between_rays must not be zero!")
		return false
	if angle_cone_of_vision == null or angle_between_rays == null:
		push_error("angle_cone_of_vision or angle_between_rays is null!")
		return false
	
	# Calculate cast_count (with error handling)
	var cast_count = int(angle_cone_of_vision / angle_between_rays) + 1
	if cast_count < 1:
		push_error("Invalid cast_count value: must be at least 1.")
		return false
	
	for index in cast_count:
		var cast_vector = max_vision_distance * Vector2.UP.rotated(rad_to_deg(angle_between_rays) * (index - cast_count) / 2.0 + deg_to_rad(180))
		vision_ray_cast_2d.target_position = cast_vector
		vision_ray_cast_2d.force_raycast_update()
		
		# Return true if any of the raycasts detect the player
		if vision_ray_cast_2d.is_colliding() && vision_ray_cast_2d.get_collider() is Player:
			return true
		# Return false if none
	return false

# Called when hit by a bullet
func bullet_impact():
	take_damage(25)

# Reduce health and check for death.
func take_damage(damage: int):
	health -= damage
	print("enemy hit! health: ", health)
	if health <= 0:
		die()

# Handle enemy death
func die():
	print("gottem")
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
	
	# Iterate through array and spawn all drops.
	for drop in drops:
		var instance = drop.instantiate()
		instance.global_position = global_position
		get_tree().get_current_scene().call_deferred("add_child", instance)
		
		# Make sure root node is a RigidBody2D
		if instance is RigidBody2D:
			print(instance)
			instance.sleeping = false
		
			# Apply random push after ensuring it's in the tree
			var random_angle = rng.randf() * TAU
			var push_direction = Vector2(cos(random_angle), sin(random_angle))
			var push_strength = 1000.0

			# Use deferred call for impulse application
			instance.call_deferred("apply_impulse", Vector2.ZERO, push_direction * push_strength)

			# Debug: Check if the instance is in the tree. Remove later.
			if not instance.is_inside_tree():
				print("Instance is not properly added to the tree!")
			else:
				print("Instance added successfully.")
			print("Linear velocity after impulse: ", instance.linear_velocity)
			


func remove_from_scene():
	queue_free()
