extends PlayerState
class_name  IdleState

func enter() -> void:
	pass

func update(_delta: float) -> void:
	if player.input.jump_pressed and player.is_grounded():
		state_machine.transition_to(state_machine.get_node("Jumping"))
		return
	if player.input.interact_pressed:
		player.try_interact()
		return

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)

	if not player.is_grounded():
		state_machine.transition_to(state_machine.get_node("Jumping"))
		return
	
	if player.input.is_crouching and player.is_grounded():
		state_machine.transition_to(state_machine.get_node("Crouching"))
		return
	
	if player.input.move_direction.length() > 0.1:
		state_machine.transition_to(state_machine.get_node("Walking"))
		return
	
	if player.is_near_cover() and player.input.cover_pressed:
		state_machine.transition_to(state_machine.get_node("Cover"))
		return
