extends Animator
class_name GuardAnimator

var guard: Guard

func update_animation(entity: CharacterBody3D) -> void:
	guard = entity as Guard
	if not guard:
		return
	_resolve_animation(guard.state_machine.current_state)

func _resolve_animation(state: GuardState) -> void:
	if state is PatrolState:
		play("stand_walking")
	elif state is AlertState:
		play("idle")
	elif state is SearchState:
		if guard.velocity.length() > 0.0:
			play("stand_walking")
		else:
			play("idle")
	elif state is ChaseState:
		play("stand_running")
	elif state is AttackState:
		play("pistol_aiming_idle")
