extends "res://state.gd"

@onready var navigation_agent_2d = $"../../NavigationAgent2D" as NavigationAgent2D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var distance_to_stop_chasing = 400
@onready var random_update_timer = $RandomUpdateTimer as RandomTimer

func enter(msg = {}) -> void:
	if owner.is_queued_for_deletion():
		return
	
	owner.current_speed = owner.chasing_speed

func _physics_process(delta: float) -> void:
	
	if navigation_agent_2d.is_navigation_finished():
		if try_to_stop_chasing():
			return
		if player == null:
			return
		
		var player_position = player.global_position
		var navigation_point = NavigationServer2D.map_get_closest_point(navigation_agent_2d.get_navigation_map(), player_position)
		navigation_agent_2d.target_position = navigation_point
	
	var next_position = navigation_agent_2d.get_next_path_position()
	(owner as EnemyArmed).move_to_position(next_position)


func try_to_stop_chasing() -> bool:
	if player == null:
		return true
	
	var player_position = player.global_position
	var distance_to_player = (owner as EnemyArmed).global_position.distance_to(player_position)
	
	if distance_to_player > distance_to_stop_chasing:
		stop_chasing()
		return true
	return false

func stop_chasing():
	var new_state = ["Idle", "Wandering"].pick_random()
	state_machine.transition_to(new_state)

func exit():
	
	random_update_timer.stop()
	owner.current_speed = owner.wandering_speed

func _on_random_update_timer_timeout() -> void:
	if try_to_stop_chasing():
		return
	start_chasing()

func start_chasing():
	if player == null:
		return
	
	var player_position = player.global_position
	var navigation_point = NavigationServer2D.map_get_closest_point(navigation_agent_2d.get_navigation_map(), player_position)
	navigation_agent_2d.target_position = navigation_point
	random_update_timer.setup()
	
