extends PlayerState
class_name UnarmedState

func enter() -> void:
	player.camera_controller.exit_aim_mode()

func update(_delta: float) -> void:
	if player.input.aim_pressed:
		if player.movement_sm.current_state is CoverState:
			return
		state_machine.transition_to(state_machine.get_node("Aiming"))
