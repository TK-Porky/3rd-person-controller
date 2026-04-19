extends PlayerState
class_name AimingState

func enter() -> void:
	if not player.action_sm.previous_state is FiringState:
		player.camera_controller.enter_aim_mode()

func exit() -> void:
	if not player.action_sm.next_state is FiringState:
		player.camera_controller.exit_aim_mode()

func update(_delta: float) -> void:
	if not player.input.aim_pressed:
		state_machine.transition_to(state_machine.get_node("Unarmed"))
		return
	
	if player.input.reload_pressed and player.weapon_manager.can_reload():
		state_machine.transition_to(state_machine.get_node("Reloading"))
		return
	
	if player.input.shoot_pressed:
		state_machine.transition_to(state_machine.get_node("Firing"))
		return

func physics_update(delta: float) -> void:
	var cam_yaw := player.camera_controller.get_yaw()
	player.skin.rotation.y = lerp_angle(
		player.skin.rotation.y,
		cam_yaw + PI,
		player.rotation_speed * delta
	)
