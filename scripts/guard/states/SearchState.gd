extends GuardState
class_name SearchState

@export var search_duration: float = 5.0
var _timer: float = 0.0
var _reached_search_point: bool = false

func enter() -> void:
	guard.player_spotted.connect(_on_player_spotted)
	guard.update_state_label(name.to_pascal_case())
	_timer = 0.0
	_reached_search_point = false
	
	if guard.last_known_player_pos != Vector3.ZERO:
		guard.navigation_agent.target_position = guard.last_known_player_pos

func exit() -> void:
	guard.player_spotted.disconnect(_on_player_spotted)

func update(delta: float) -> void:
	if not _reached_search_point:
		return
	
	_timer += delta
	if _timer >= search_duration:
		state_machine.transition_to(state_machine.patrol)

func physics_update(_delta: float) -> void:
	if _reached_search_point:
		return
	
	if guard.is_nav_finished():
		_reached_search_point = true
		guard.stop()
	else:
		var next_pos := guard.navigation_agent.get_next_path_position()
		var dir := (next_pos - guard.global_position).normalized()
		if dir.length_squared() > 0.001:
			guard.velocity.x = dir.x * guard.move_speed
			guard.velocity.z = dir.z * guard.move_speed
			guard.rotate_body_toward(Vector3(dir.x, 0.0, dir.z))

func _on_player_spotted(_player: Player) -> void:
	state_machine.transition_to(state_machine.chase)
