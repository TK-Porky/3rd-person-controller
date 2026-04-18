extends PlayerState
class_name CrouchingState

func enter() -> void:
	player.set_collision_height(player.crouch_height)
	player.camera_controller.enter_crouch_mode()

func exit() -> void:
	player.camera_controller.exit_crouch_mode()
	player.set_collision_height(player.normal_height)

func update(_delta: float) -> void:
	if player.input.interact_pressed:
		player.try_interact()
		return

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	
	var move_dir := _get_camera_relative_direction()
	
	if move_dir.length() > 0.1:
		player.apply_movement(move_dir, player.crouch_speed, delta)
		player.rotate_toward(move_dir, delta)
	else:
		player.apply_movement(Vector3.ZERO, 0.0, delta)
		
	_check_transitions()

func is_moving() -> bool:
	var move_dir := Vector3(player.input.move_direction.x,0.0,player.input.move_direction.z)
	return move_dir.length() > 0.1

func _check_transitions() -> void:
	if not player.is_grounded():
		player.input.cancel_crouch()
		state_machine.transition_to(state_machine.get_node("Jumping"))
		return
	
	if not player.input.is_crouching and not player.head_detector.is_colliding():
		var next := "Walking" if player.input.move_direction.length() > 0.1 else "Idle"
		state_machine.transition_to(state_machine.get_node(next))

func _get_camera_relative_direction() -> Vector3:
	var cam_basis := player.camera_controller.get_camera_basis()
	var input := player.input.move_direction
	var direction := cam_basis.z * input.z + cam_basis.x * input.x
	direction.y = 0.0
	return direction.normalized()
