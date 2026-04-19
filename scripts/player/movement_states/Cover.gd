extends PlayerState
class_name CoverState

enum Phase { SNAPPING, ACTIVE }
var _phase := Phase.SNAPPING

# Lean
enum LeanSide { NONE, LEFT, RIGHT }
var _lean_side := LeanSide.NONE
var _lean_offset := Vector3.ZERO
var _is_leaning := false

const LEAN_DISTANCE := 1.0
const LEAN_SPEED := 15.0

var _is_popping_up := false
var _cover_normal := Vector3.ZERO
var _target_position := Vector3.ZERO
var _base_cover_position := Vector3.ZERO
var _is_low_cover := false
var _lateral_input := 0.0

func enter() -> void:
	_phase = Phase.SNAPPING
	_cover_normal = player.body_detector.get_collision_normal()
	_cover_normal = Vector3(_cover_normal.x, 0.0, _cover_normal.z).normalized()
	_target_position = _calculate_snap_target()

func exit() -> void:
	player.set_collision_height(player.normal_height)

func update(_delta: float) -> void:
	if player.input.interact_pressed:
		player.try_interact()
		return
	
	if (_is_leaning or _is_popping_up) and player.input.shoot_pressed:
		if player.weapon_manager.can_shoot():
			player.action_sm.transition_to(
				player.action_sm.get_node("Firing")
			)
		return
	
	if (_is_leaning or _is_popping_up) and player.input.reload_pressed:
		if player.weapon_manager.can_reload():
			player.action_sm.transition_to(
				player.action_sm.get_node("Reloading")
			)
		return

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	
	match _phase:
		Phase.SNAPPING: _update_snapping(delta)
		Phase.ACTIVE: _update_active(delta)

func _update_snapping(delta: float) -> void:
	player.global_position = player.global_position.move_toward(
		_target_position,
		player.cover_snap_speed * delta
	)
	
	if player.global_position.distance_to(_target_position) < 0.05:
		_enter_active_phase()

func _enter_active_phase() -> void:
	_phase = Phase.ACTIVE
	_base_cover_position = player.global_position
	_lean_side = LeanSide.NONE
	_is_leaning = false
	_is_low_cover = not player.top_detector.is_colliding()
	_apply_cover_stance()

func _update_active(delta: float) -> void:
	_update_cover_stance()
	_handle_cover_movement()
	_handle_lean(delta)
	_handle_pop_up()
	_check_exit_transitions()
	_orient_skin(delta)

func _update_cover_stance() -> void:
	if _is_leaning or _is_popping_up:
		return
	
	var was_low := _is_low_cover
	_is_low_cover = not player.top_detector.is_colliding()
	
	if _is_low_cover != was_low:
		_apply_cover_stance()
		
func _apply_cover_stance() -> void:
	if _is_low_cover:
		player.camera_controller.enter_crouch_mode()
		player.set_collision_height(player.crouch_height)
	else:
		player.camera_controller.exit_crouch_mode()
		player.set_collision_height(player.normal_height)

func _handle_cover_movement() -> void:
	var wall_right := _cover_normal.cross(Vector3.UP).normalized()
	
	# Leaning - Active Phase
	if _is_leaning:
		var lean_target := _base_cover_position + _lean_offset
		var lean_direction := (lean_target - player.global_position)
		
		if lean_direction.length() < 0.02:
			player.velocity.x = 0.0
			player.velocity.z = 0.0
		else:
			player.velocity.x = lean_direction.x * LEAN_SPEED
			player.velocity.z = lean_direction.z * LEAN_SPEED
		
		player.move_and_slide()
		return
	
	# Leaning - Return to Normal Phase
	if _lean_offset.length() > 0.02:
		var return_target := _base_cover_position + _lean_offset
		var return_direction := return_target - player.global_position
		
		if return_direction.length() < 0.02:
			player.velocity.x = 0.0
			player.velocity.z = 0.0
		else:
			player.velocity.x = return_direction.x * LEAN_SPEED
			player.velocity.z = return_direction.z * LEAN_SPEED
		
		player.move_and_slide()
		return
	
	if _is_popping_up:
		player.velocity.x = 0.0
		player.velocity.z = 0.0
		player.move_and_slide()
		return
	
	_lateral_input = -player.input.move_direction.x
	
	var can_move_right := player.body_detector_right.is_colliding()
	var can_move_left := player.body_detector_left.is_colliding()
	
	if (_lateral_input > 0.1 and not can_move_right) or (_lateral_input < -0.1 and not can_move_left):
		_lateral_input = 0.0
	
	if abs(_lateral_input) > 0.1:
		_base_cover_position = player.global_position
		player.velocity = wall_right * (_lateral_input * player.cover_move_speed)
	else:
		player.velocity.x = 0.0
		player.velocity.z = 0.0
	
	player.move_and_slide()

func _handle_lean(delta: float) -> void:
	var wants_aim := player.input.aim_pressed
	var wall_right := _cover_normal.cross(Vector3.UP).normalized()
	
	if not wants_aim:
		_set_leaning(false, LeanSide.NONE)
	elif not _is_leaning:
		var at_left_edge := not player.body_detector_left.is_colliding()
		var at_right_edge := not player.body_detector_right.is_colliding()
		
		var at_real_right_edge := at_right_edge and not at_left_edge
		var at_real_left_edge  := at_left_edge  and not at_right_edge

		if abs(_lateral_input) < 0.1:
			if at_real_right_edge:
				var right_offset := wall_right * LEAN_DISTANCE
				if _has_floor_at_lean_target(right_offset):
					_set_leaning(true, LeanSide.RIGHT)
			elif at_real_left_edge:
				var left_offset := -wall_right * LEAN_DISTANCE
				if _has_floor_at_lean_target(left_offset):
					_set_leaning(true, LeanSide.LEFT)
	
	# Calculate the offset of the movement
	var target_offset := Vector3.ZERO
	
	match _lean_side:
		LeanSide.RIGHT:
			target_offset = wall_right * LEAN_DISTANCE
		LeanSide.LEFT:
			target_offset = -wall_right * LEAN_DISTANCE
	
	# Interpolate the movement between the position and the offset position
	_lean_offset = _lean_offset.lerp(target_offset, LEAN_SPEED * delta)

func _handle_pop_up() -> void:
	var can_pop_up := (
		_is_low_cover 
		and player.input.aim_pressed 
		and _lean_side == LeanSide.NONE 
		and not player.head_detector.is_colliding() 
	)

	var was_popping := _is_popping_up

	if can_pop_up:
		_is_popping_up = true
	else:
		_is_popping_up = false

	if _is_popping_up and not was_popping:
		player.set_collision_height(player.normal_height)
		player.camera_controller.exit_crouch_mode()
		player.camera_controller.enter_aim_mode()

	elif not _is_popping_up and was_popping:
		player.set_collision_height(player.crouch_height)
		player.camera_controller.enter_crouch_mode()
		player.camera_controller.exit_aim_mode()

func _set_leaning(leaning: bool, side: LeanSide) -> void:
	var was_leaning := _is_leaning
	_is_leaning = leaning
	_lean_side = side
	
	if _is_leaning and not was_leaning:
		player.camera_controller.enter_aim_mode()
	elif not _is_leaning and was_leaning:
		player.camera_controller.exit_aim_mode()

func _check_exit_transitions() -> void:
	var wants_exit := player.input.cover_pressed or player.input.move_direction.z > 0.3

	if wants_exit:
		if _is_low_cover:
			player.camera_controller.exit_crouch_mode()
		player.camera_controller.exit_aim_mode()
		state_machine.transition_to(state_machine.get_node("Idle"))

func get_lean_side() -> LeanSide:
	return _lean_side

func is_popping_up() -> bool:
	return _is_popping_up

func is_leaning() -> bool:
	return _is_leaning

func is_snapping() -> bool:
	return _phase == Phase.SNAPPING

func is_moving_laterally() -> bool:
	return _phase == Phase.ACTIVE and abs(_lateral_input) > 0.1

func is_low_cover() -> bool:
	return _is_low_cover

func is_moving_in_cover() -> bool:
	return abs(_lateral_input) > 0.1

func get_cover_direction() -> float:
	return _lateral_input 

func _calculate_snap_target() -> Vector3:
	var flat_normal := Vector3(_cover_normal.x, 0.0, _cover_normal.z).normalized()
	var collision_point := player.body_detector.get_collision_point()
	const CAPSULE_RADIUS := 0.25
	var target := collision_point + flat_normal * CAPSULE_RADIUS
	target.y = player.global_position.y
	return target

func _orient_skin(delta: float) -> void:
	var sensor_angle := atan2(_cover_normal.x, _cover_normal.z)
	player.rotate_sensors(sensor_angle)
	
	var skin_target_angle: float
	if _is_leaning:
		skin_target_angle = player.camera_controller.get_yaw() + PI
	elif _is_popping_up:
		skin_target_angle = player.camera_controller.get_yaw() + PI
	else:
		skin_target_angle = sensor_angle
	
	var current_angle := player.skin.global_rotation.y
	player.skin.rotation.y = lerp_angle(
		current_angle,
		skin_target_angle,
		player.rotation_speed * delta
	)

func _has_floor_at_lean_target(target_offset: Vector3) -> bool:
	var space_state := player.get_world_3d().direct_space_state
	
	var lean_target := _base_cover_position + target_offset
	var ray_start   := lean_target + Vector3.UP * 0.1
	var ray_end     := lean_target + Vector3.DOWN * 1.0

	var query := PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.exclude = [player.get_rid()]   # ignore le joueur lui-même

	var result := space_state.intersect_ray(query)
	return not result.is_empty()
