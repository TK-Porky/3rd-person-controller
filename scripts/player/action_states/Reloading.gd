extends PlayerState
class_name ReloadingState

const RELOAD_DURATION := 2.3

var _timer := 0.0
var _came_from_aiming := false

func enter() -> void:
	_timer = RELOAD_DURATION
	_came_from_aiming = player.action_sm.previous_state is AimingState or player.action_sm.previous_state is FiringState

func update(delta: float) -> void:
	_timer -= delta

	if _timer <= 0.0:
		player.weapon_manager.reload()
		var next := "Aiming" if _came_from_aiming and player.input.aim_pressed else "Unarmed"
		state_machine.transition_to(state_machine.get_node(next))

func is_reloading() -> bool:
	return true
