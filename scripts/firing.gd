extends State

func enter(msg = {}) -> void:
	# Enable VisionRayCast2D when entering the state
	owner.get_node("VisionRayCast2D").enabled = true

func exit() -> void:
	pass

func update(_delta: float) -> void:
	
	# Ensure the player exists in the main scene
	var player = get_tree().get_current_scene().get_node_or_null("Player")
	
	if player:
		# Rotate the enemy to face the player
		owner.look_at(player.global_position)
		
	owner.fire()
	
	#if !(owner as enemy).search_for_player_with_raycast():
	#	state_machine.transition_to("Chase")
