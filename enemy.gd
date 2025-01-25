extends CharacterBody2D

class_name enemy

@onready var navigation_agent_2d = $NavigationAgent2D
@onready var state_machine = $StateMachine as StateMachine
@onready var vision_ray_cast_2d = $VisionRayCast2D as RayCast2D

@export var healthpack_scene: PackedScene

@export_group("Locomotion")
@export var rotation_speed: float = 2
@export var wandering_speed = 150
@export var navigation_target: CharacterBody2D
@export var chasing_speed = 200

@export_group("Scanning for player")
@export var angle_cone_of_vision = 90
@export var max_vision_distance = 2000
@export var angle_between_rays = 5

var current_speed
var health = 100  # Add health for the enemy

func _ready():
	var navigation_map = get_tree().get_first_node_in_group("tilemap").get_navigation_map()
	NavigationServer2D.agent_set_map(navigation_agent_2d.get_rid(), navigation_map)
	navigation_agent_2d.set_navigation_map(navigation_map)
	current_speed = wandering_speed

func _process(delta):
	search_for_player_with_raycast()

func move_to_position(target_position: Vector2):
	var motion = position.direction_to(target_position) * current_speed
	navigation_agent_2d.set_velocity(motion)
	look_at(target_position)
	rotation -= deg_to_rad(180) # Corrects the enemy sprite walking backwards
	velocity = motion
	move_and_slide()

func search_for_player_with_raycast():

	# Error handling for enemy vision variables
	if angle_between_rays == 0:
		push_error("angle_between_rays must not be zero!")
		return
	if angle_cone_of_vision == null or angle_between_rays == null:
		push_error("angle_cone_of_vision or angle_between_rays is null!")
		return

	# Calculate cast_count (with error handling)
	var cast_count = int(angle_cone_of_vision / angle_between_rays) + 1
	if cast_count < 1:
		push_error("Invalid cast_count value: must be at least 1.")
		return
	
	for index in cast_count:
		var cast_vector = max_vision_distance * Vector2.UP.rotated(rad_to_deg(angle_between_rays) * (index - cast_count) / 2.0 + deg_to_rad(180))
		vision_ray_cast_2d.target_position = cast_vector
		vision_ray_cast_2d.force_raycast_update()
		
		if vision_ray_cast_2d.is_colliding() && vision_ray_cast_2d.get_collider() is Player:
			state_machine.transition_to("Firing")

# Called when hit by a bullet
func bullet_impact():
	take_damage(25)

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
	
	var healthpack_instance = healthpack_scene.instantiate()
	healthpack_instance.global_position = global_position # Set spawn position
	
	# Put physics here - "push" the item in random direction when dropped
	
	get_tree().get_current_scene().add_child(healthpack_instance) # Spawn item

func remove_from_scene():
	queue_free()
