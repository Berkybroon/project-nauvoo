extends RigidBody2D

var speed = 3600
var lifetime: float = 3.0 # Seconds before an unspent bullet cleans itself up

func _ready():
	# Enable contact reporting to detect collisions
	contact_monitor = true
	max_contacts_reported = 1

	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(_delta):
	# Set the bullet's linear velocity to move it
	linear_velocity = Vector2(speed, 0).rotated(rotation)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Check for collisions
	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i)
		if collider:
			_on_collision(collider)
			return

func _on_collision(collider):

	# Already spent on an earlier contact
	if is_queued_for_deletion():
		return

	# Remove bullet from scene
	queue_free()

	# Check if collider has a method on-impact
	if collider.has_method("bullet_impact"):
		collider.bullet_impact()
