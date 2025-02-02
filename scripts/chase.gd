extends "res://scripts/state.gd"

@onready var navigation_agent_2d = $"../../NavigationAgent2D" as NavigationAgent2D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var distance_to_stop_chasing = 300
@onready var random_update_timer = $RandomUpdateTimer as RandomTimer
@onready var self_position = $"../../".global_position

# Begin chasing the player at declared speed immediately upon entering state.
func enter(msg = {}) -> void:
	
	if owner.is_queued_for_deletion():
		return
	
	owner.current_speed = owner.chasing_speed
	update_navigation_path()


func _physics_process(delta: float) -> void:
	
	self_position = $"../../".global_position
	var next_position = navigation_agent_2d.get_next_path_position()
	(owner as EnemyArmed).move_to_position(next_position)
	

# Should the enemy try to stop chasing the player? Called on timer
func try_to_stop_chasing() -> bool:
	if player == null:
		return true
	
	var player_position = player.global_position
	var distance_to_player = (owner as EnemyArmed).global_position.distance_to(player_position)
	
	if distance_to_player > distance_to_stop_chasing:
		return true
	return false

# Return to idle states when player escapes. To be replaced with better behaviour later.
func stop_chasing():
	var new_state = ["Idle", "Wandering"].pick_random()
	state_machine.transition_to(new_state)

# Stop timers and revert to normal idle speed to exit gracefully
func exit():
	
	random_update_timer.stop()
	owner.current_speed = owner.wandering_speed

func _on_random_update_timer_timeout() -> void:
	if try_to_stop_chasing():
		return
	update_navigation_path()

func update_navigation_path():
	
	if player == null:
		return
	
	var player_position = player.global_position
	var navigation_point = NavigationServer2D.map_get_closest_point(navigation_agent_2d.get_navigation_map(), player_position)
	
	navigation_agent_2d.target_position = navigation_point
