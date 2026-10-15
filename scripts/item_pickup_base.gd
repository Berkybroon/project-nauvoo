extends RigidBody2D

var push_force = 500
var player_in_range = false
var rng = RandomNumberGenerator.new()
var push_applied := false
var push_vector := Vector2.ZERO  # Store the push direction

@export var item_resource: ItemBase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Hide pickup prompt
	$PickupPrompt.visible = false
	
	# Enable contact reporting to detect collisions
	contact_monitor = true
	max_contacts_reported = 1
	
	# Connect signals from pickup range area
	$Area2D.connect("body_entered", Callable(self, "_on_body_entered"))
	$Area2D.connect("body_exited", Callable(self, "_on_body_exited"))
	
	# Generate push direction
	var random_angle = rng.randf() * TAU
	push_vector = Vector2(cos(random_angle), sin(random_angle)) * push_force

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Positioning and rotation correction
	$PickupPrompt.rotation = -rotation
	$PickupPrompt.global_position.x = global_position.x - 20
	$PickupPrompt.global_position.y = global_position.y - 100
	
	# Pickup action
	if player_in_range:
		if Input.is_action_just_pressed("interact"):
			# Try to add to player inventory
			if get_tree().current_scene.get_node("HUD/Inventory").add_item(item_resource):
				queue_free()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	
	if not push_applied:
		set_deferred("sleeping", false)
		linear_velocity = push_vector / mass
		push_applied = true  # Ensure it's only applied once

# Signal when a body enters the detection area
func _on_body_entered(body):
	if body is Player:
		$PickupPrompt.visible = true
		player_in_range = true

# Signal when a body exits the detection area
func _on_body_exited(body):
	if body is Player:
		$PickupPrompt.visible = false
		player_in_range = false
