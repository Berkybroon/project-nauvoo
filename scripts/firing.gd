extends State

# How long the player can be out of sight before the enemy gives chase instead
const LOSE_SIGHT_TIME := 1.5

var time_since_seen: float = 0.0

func enter(msg = {}) -> void:
	# Enable VisionRayCast2D when entering the state
	owner.get_node("VisionRayCast2D").enabled = true
	time_since_seen = 0.0

func exit() -> void:
	pass

func update(delta: float) -> void:

	# Only shoot while the player is actually visible (no firing through walls)
	if (owner as Enemy).search_for_player_with_raycast():
		time_since_seen = 0.0

		# Ensure the player exists in the main scene
		var player = get_tree().get_current_scene().get_node_or_null("Player")
		if player:
			# Rotate the enemy to face the player
			owner.look_at(player.global_position)

		owner.fire()
	else:
		time_since_seen += delta
		if time_since_seen >= LOSE_SIGHT_TIME:
			state_machine.transition_to("Chase")
