extends GuardState
class_name PatrolState

func enter() -> void:
	guard.player_spotted.connect(_on_player_spotted)
	guard.noise_heard.connect(_on_noise_heard)
	guard.update_state_label(name.to_pascal_case())
	
	if guard.waypoints.is_empty():
		return
	_set_next_waypoint()

func exit() -> void:
	guard.player_spotted.disconnect(_on_player_spotted)
	guard.noise_heard.disconnect(_on_noise_heard)

func physics_update(_delta: float) -> void:
	if guard.waypoints.is_empty():
		return
	
	if guard.is_nav_finished():
		guard.advance_waypoint()
		_set_next_waypoint()
	else:
		guard.move_toward_target(guard.get_current_waypoint().global_position, guard.move_speed)

func _set_next_waypoint() -> void:
	var wp := guard.get_current_waypoint()
	if wp:
		guard.navigation_agent.target_position = wp.global_position

func _on_player_spotted(_player: Player) -> void:
	state_machine.transition_to(state_machine.chase)

func _on_noise_heard(position: Vector3, _intensity: float) -> void:
	guard.last_known_player_pos = position
	state_machine.transition_to(state_machine.alert)
