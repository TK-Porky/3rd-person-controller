extends PlayerState
class_name AimingState

func enter() -> void:
	player.camera_controller.enter_aim_mode()

func exit() -> void:
	player.camera_controller.exit_aim_mode()

func update(_delta: float) -> void:
	if not player.input.aim_pressed:
		state_machine.transition_to(state_machine.get_node("Unarmed"))

func physics_update(delta: float) -> void:
	var cam_yaw := player.camera_controller.get_yaw()
	player.skin.rotation.y = lerp_angle(
		player.skin.rotation.y,
		cam_yaw + PI,
		player.rotation_speed * delta
	)
