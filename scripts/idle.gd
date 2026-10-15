extends "res://scripts/state.gd"

@onready var idle_timer = $IdleTimer
@onready var rotation_timer = $RotationTimer
@onready var tween: Tween = null

var base_rotation: float = 0.0
var target_rotation: float = 0.0
var rotation_range: float = deg_to_rad(30) # ±30° max rotation range
var rotating_left: bool = true # Keeps track of rotation direction

func enter(msg = {}) -> void:
	owner.velocity = Vector2.ZERO
	base_rotation = normalize_angle(owner.rotation) # Lock in starting rotation
	schedule_next_rotation()
	idle_timer.setup()

func exit() -> void:
	if tween and tween.is_running():
		tween.kill()
	rotation_timer.stop()
	idle_timer.stop()

func physics_update(_delta: float) -> void:
	if not tween or not tween.is_running():
		owner.rotation = target_rotation

	if (owner as Enemy).search_for_player_with_raycast():
		state_machine.transition_to(["Firing", "Chase"].pick_random())

func _on_rotation_timer_timeout() -> void:
	schedule_next_rotation()

func _on_idle_timer_timeout() -> void:
	state_machine.transition_to("Wandering")
	idle_timer.stop()

func schedule_next_rotation() -> void:
	if tween and tween.is_running():
		return  # Prevents multiple rotations from stacking

	# Calculate the next rotation target, alternating left and right
	var new_rotation = base_rotation + (-rotation_range if rotating_left else rotation_range)
	target_rotation = normalize_angle(new_rotation)
	rotating_left = !rotating_left  # Flip direction for the next cycle

	# Ensure the rotation happens in the correct direction (NO FLIPPING)
	target_rotation = get_closest_rotation(owner.rotation, target_rotation)

	# Smoothly animate rotation using Tween
	tween = get_tree().create_tween()
	tween.tween_property(owner, "rotation", target_rotation, 1.2) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)

	# After rotation completes, lock the rotation and schedule next move
	tween.tween_callback(func():
		owner.rotation = target_rotation
		base_rotation = target_rotation  # Update base_rotation to the new target
		rotation_timer.start(randf_range(1.5, 3.0))
	)

# Normalize angle to stay within -π to π (prevent unintended full turns)
func normalize_angle(angle: float) -> float:
	angle = fmod(angle, 2 * PI)  # Normalize to [0, 2π]
	if angle > PI:
		angle -= 2 * PI  # Convert to [-π, π]
	elif angle < -PI:
		angle += 2 * PI
	return angle

# Ensure the enemy rotates in the correct direction without flipping
func get_closest_rotation(current_angle: float, target_angle: float) -> float:
	var diff = normalize_angle(target_angle - current_angle)
	return current_angle + diff
