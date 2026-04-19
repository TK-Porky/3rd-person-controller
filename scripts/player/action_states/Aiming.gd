extends PlayerState
class_name AimingState

func enter() -> void:
	var from_firing_in_cover := (
		player.action_sm.previous_state is FiringState 
		and player.is_in_cover()
	)
	if ( 
		not player.action_sm.previous_state is FiringState 
		and not from_firing_in_cover
	):
		player.camera_controller.enter_aim_mode()

func exit() -> void:
	var to_firing_in_cover := (
		player.action_sm.next_state is FiringState
		and player.is_in_cover()
	)
	if (
		not player.action_sm.next_state is FiringState
		and not to_firing_in_cover
	):
		player.camera_controller.exit_aim_mode()

func update(_delta: float) -> void:
	if player.is_in_cover():
		state_machine.transition_to(state_machine.get_node("Unarmed"))
		return
	
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
