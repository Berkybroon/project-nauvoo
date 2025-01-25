extends RigidBody2D

var speed = 3600

func _ready():
	# Enable contact reporting to detect collisions
	contact_monitor = true
	max_contacts_reported = 1

func _physics_process(delta):
	# Set the bullet's linear velocity to move it
	linear_velocity = Vector2(speed, 0).rotated(rotation)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Check for collisions
	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i)
		if collider:
			_on_collision(collider)

func _on_collision(collider):
	
	# Remove bullet from scene
	queue_free()
	
	# Check if collider has a method on-impact
	if collider.has_method("bullet_impact"):
		collider.bullet_impact()
