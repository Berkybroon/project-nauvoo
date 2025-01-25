extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		# Enable contact reporting to detect collisions
	contact_monitor = true
	max_contacts_reported = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Check for collisions
	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i)
		
		if collider is Player:
			if collider.health < collider.max_health:
				collider.health += 50
				queue_free()
