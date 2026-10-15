extends "res://scripts/item_pickup_base.gd"

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	super(state)
	
	# Automatic pickup & heal if player is missing health
	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i)
		if collider is Player and collider.health < collider.max_health:
			collider.heal(50)
			queue_free()
