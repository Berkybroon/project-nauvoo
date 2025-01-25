extends "res://state.gd"

@onready var navigation_agent_2d = $"../../NavigationAgent2D"
var wandering_radius = 300

var random_position_in_radius

func enter(msg = {}) -> void:
	move_to_next_random_location()

func move_to_next_random_location():
	random_position_in_radius = get_random_position_in_radius(wandering_radius)
	navigation_agent_2d.target_position = random_position_in_radius

func physics_update(delta):
	# Check if the target position is valid and reachable
	if navigation_agent_2d.target_position != Vector2.ZERO and (
		navigation_agent_2d.is_navigation_finished() or 
		!navigation_agent_2d.is_target_reachable()
	):
		state_machine.transition_to("Idle")
	else:
		# Continue moving towards the next navigation point
		var next_position = navigation_agent_2d.get_next_path_position()
		(owner as enemy).move_to_position(next_position)

func get_random_position_in_radius(wandering_radius: float) -> Vector2:
	# Get the global position of the owner
	var global_position = owner.global_position
	# Generate a random angle in radians and calculate a random offset
	var random_angle = randf() * TAU  # TAU is 2π radians
	var random_offset = Vector2.from_angle(random_angle) * randf_range(0, wandering_radius)
	# Calculate the random point relative to the global position
	var random_point = global_position + random_offset
	# Find the closest navigable point on the map
	var navigation_point = NavigationServer2D.map_get_closest_point(navigation_agent_2d.get_navigation_map(),random_point)
	# Return the navigable point
	return navigation_point

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
