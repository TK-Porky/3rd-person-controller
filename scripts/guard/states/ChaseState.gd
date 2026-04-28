extends GuardState
class_name ChaseState

@export var attack_range: float = 8.0

func enter() -> void:
	guard.player_lost.connect(_on_player_lost)
	guard.update_state_label(name.to_pascal_case())
	pass

func exit() -> void:
	guard.player_lost.disconnect(_on_player_lost)

func update(_delta: float) -> void:
	if guard.player_ref == null:
		state_machine.transition_to(state_machine.search)
		return
	
	guard.last_known_player_pos = guard.player_ref.global_position
	
	var dist := guard.global_position.distance_to(guard.player_ref.global_position)
	if dist <= attack_range:
		state_machine.transition_to(state_machine.attack)

func physics_update(_delta: float) -> void:
	if guard.player_ref == null:
		return
	guard.move_toward_target(guard.player_ref.global_position, guard.chase_speed)

func _on_player_lost() -> void:
	state_machine.transition_to(state_machine.search)
