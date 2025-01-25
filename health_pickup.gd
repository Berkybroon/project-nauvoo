extends RigidBody2D

var player_in_range = false

@export var item_resource: Item

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
			if $"../HUD/Inventory".add_item(item_resource):
				queue_free()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	
	# Check for collisions
	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i)
		
		# Automatic pickup & heal if player is missing health
		if collider is Player:
			if collider.health < collider.max_health:
				collider.health += 50
				queue_free()

# Signal when a body enters the detection area
func _on_body_entered(body):
	if body.name == "Player":
		$PickupPrompt.visible = true
		player_in_range = true

# Signal when a body exits the detection area
func _on_body_exited(body):
	if body.name == "Player":
		$PickupPrompt.visible = false
		player_in_range = false
