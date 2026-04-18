extends PlayerState
class_name  WalkingState

func enter() -> void:
	pass

func update(_delta: float) -> void:
	if player.input.interact_pressed:
		player.try_interact()
		return

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	
	var move_dir := _get_camera_relative_direction()
	var speed := _resolve_speed()
	
	player.apply_movement(move_dir, speed, delta)
	
	if not player.is_aiming():
		player.rotate_toward(move_dir, delta)
	
	_check_transitions(move_dir)

func is_sprinting() -> bool:
	return player.input.is_sprinting

func _resolve_speed() -> float:
	if player.is_aiming():
		return player.move_speed * 0.5
	if player.input.is_sprinting:
		return player.sprint_speed
	return player.move_speed

func _check_transitions(dir: Vector3) -> void:
	if not player.is_grounded():
		state_machine.transition_to(state_machine.get_node("Jumping"))
		return
	
	if player.input.jump_pressed and player.is_grounded():
		state_machine.transition_to(state_machine.get_node("Jumping"))
		return
	
	if player.input.is_crouching and player.is_grounded():
		state_machine.transition_to(state_machine.get_node("Crouching"))
		return
	
	if dir.length() < 0.1:
		state_machine.transition_to(state_machine.get_node("Idle"))
		return

func _update_animation() -> void:
	if player.input.is_sprinting:
		player.skin.stand_running()
		return
	player.skin.stand_walking()

func _get_camera_relative_direction() -> Vector3:
	var cam_basis := player.camera_controller.get_camera_basis()
	var input := player.input.move_direction
	var direction := cam_basis.z * input.z + cam_basis.x * input.x
	direction.y = 0.0
	return direction.normalized()
