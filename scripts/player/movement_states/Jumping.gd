extends PlayerState
class_name JumpingState

# Landing Type
enum LandingType { NONE, SOFT, HARD }  # The type of landing animation

# Jump Phase
enum Phase { AIRBORNE, LANDING }   # The Phase of the jump
var _phase := Phase.AIRBORNE       # Current phase
var _landing_timer := 0.0          # Timer for the animation

# Height of Jump
const FALL_THRESHOLD_SOFT := 1.5   # The Limit of the height to be considerated as small
const FALL_THRESHOLD_HARD := 4.0   # The Limit of the height to be considerated as high

var _jump_origin_y := 0.0   # The origin point of the jump
var _fall_height := 0.0     # The Height of the fall based on the current height and the origin

# Length Duration of landing animation
#const LANDING_DURATION_SOFT := 2.0  # Soft Landing Animation Duration for small height
const LANDING_DURATION_HARD := 2.0   # Hard Landing Animation Duration for hight height 

const COYOTE_TIME := 0.12
const JUMP_BUFFER_TIME := 0.12
const AIR_CONTROL := 0.4

var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0
var _has_jumped := false
var _was_grounded := false

func enter() -> void:
	_has_jumped = false
	_coyote_timer = COYOTE_TIME
	_jump_buffer_timer = 0.0
	_phase = Phase.AIRBORNE
	_landing_timer = 0.0
	_fall_height = 0.0
	_was_grounded = player.is_grounded()
	
	_jump_origin_y = player.global_position.y
	
	if _was_grounded:
		_apply_jump()
	else:
		player.reset_vertical_velocity()

func exit() -> void:
	_has_jumped = false
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0

func update(delta: float) -> void:
	if player.input.jump_pressed:
		_jump_buffer_timer = JUMP_BUFFER_TIME
		
	if _jump_buffer_timer > 0.0:
		_jump_buffer_timer -= delta

func physics_update(delta: float) -> void:
	match _phase:
		Phase.AIRBORNE: 
			_update_airbone(delta)
		Phase.LANDING: 
			_update_landing(delta)

func _update_airbone(delta: float) -> void:
	_update_timers(delta)
	_handle_air_movement(delta)
	
	if player.velocity.y > 0.0:
		_jump_origin_y = player.global_position.y
	
	_check_landing()

func _check_landing() -> void:
	if not player.is_grounded(): return
	
	if _jump_buffer_timer > 0.0:
		_apply_jump()
		return
	
	_fall_height = _jump_origin_y - player.global_position.y
	
	_phase = Phase.LANDING
	_landing_timer = _resolve_landing_duration()

func _resolve_landing_duration() -> float:
	if _fall_height < FALL_THRESHOLD_SOFT:
		return 0.0
	if _fall_height < FALL_THRESHOLD_HARD:
		return 0.0 # TO-DO: Use LANDING_DURATION_SOFT for a small landing animation
	return LANDING_DURATION_HARD

func _update_timers(delta: float) -> void:
	if not player.is_grounded() and _coyote_timer > 0.0:
		_coyote_timer -= delta

	if player.input.jump_pressed and _coyote_timer > 0.0 and not _has_jumped:
		_apply_jump()

func _handle_air_movement(delta: float) -> void:
	var move_dir := _get_camera_relative_direction()
	
	if move_dir.length() > 0.1:
		var target_velocity := move_dir * player.move_speed
		player.velocity.x = lerp(player.velocity.x, target_velocity.x, AIR_CONTROL * delta * 10.0)
		player.velocity.z = lerp(player.velocity.z, target_velocity.z, AIR_CONTROL * delta * 10.0)
		player.rotate_toward(move_dir, delta)

	player.apply_gravity(delta)
	player.move_and_slide()

func _update_landing(delta: float) -> void:
	player.apply_gravity(delta)
	player.velocity.x = lerp(player.velocity.x, 0.0, 10.0 * delta)
	player.velocity.z = lerp(player.velocity.z, 0.0, 10.0 * delta)
	player.move_and_slide()
	_landing_timer -= delta
	if player.input.jump_pressed:
		_phase = Phase.AIRBORNE
		_apply_jump()
		return
	
	if _landing_timer <= 0.0:
		var has_input := player.input.move_direction.length() > 0.1
		state_machine.transition_to(state_machine.get_node("Walking" if has_input else "Idle"))

func is_rising() -> bool:
	return player.velocity.y > 0.5

func is_landing() -> bool:
	return _phase == Phase.LANDING

func get_landing_type() -> LandingType:
	if not is_landing():
		return LandingType.NONE
	if _fall_height < FALL_THRESHOLD_HARD:
		return LandingType.SOFT
	return LandingType.HARD

func _apply_jump() -> void:
	player.apply_jump()
	_has_jumped = true
	_coyote_timer = 0.0

func _get_camera_relative_direction() -> Vector3:
	var cam_basis := player.camera_controller.get_camera_basis()
	var input := player.input.move_direction
	var direction := cam_basis.z * input.z + cam_basis.x * input.x
	direction.y = 0.0
	return direction.normalized()
