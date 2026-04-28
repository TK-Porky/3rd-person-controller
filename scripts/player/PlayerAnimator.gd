extends Animator
class_name PlayerAnimator

func update_animation(entity: CharacterBody3D) -> void:
	var player := entity as Player
	if not player:
		return

	var movement_state := player.movement_sm.current_state
	var is_aiming      := player.is_aiming()
	var is_crouching   := player.input.is_crouching
	var is_firing      := player.is_firing()
	var is_reloading   := player.is_reloading()

	_resolve_animation(movement_state, is_aiming, is_crouching, is_firing, is_reloading)

func _resolve_animation(movement_state: PlayerState, is_aiming: bool, is_crouching: bool, is_firing: bool, is_reloading: bool) -> void:
	if is_reloading:
		play("reloading")
		return
	if movement_state is CoverState:
		_play_cover_animation(movement_state, is_aiming)
		return
	if is_firing:
		play("pistol_aiming_idle")
		return
	if movement_state is JumpingState:
		match movement_state.get_landing_type():
			JumpingState.LandingType.HARD:
				play("landing")
				return
			_:
				pass
		play("jumping_up" if movement_state.is_rising() else "falling")
		return
	match [is_crouching, is_aiming]:
		[true, true]:   _play_crouch_aim(movement_state)
		[true, false]:  _play_crouch(movement_state)
		[false, true]:  _play_aim(movement_state)
		[false, false]: _play_normal(movement_state)

func _play_normal(state: PlayerState) -> void:
	if state is IdleState:
		play("idle")
	elif state is WalkingState:
		play("stand_running" if state.is_sprinting() else "stand_walking")

func _play_aim(state: PlayerState) -> void:
	if state is IdleState:
		play("pistol_aiming_idle")
	elif state is WalkingState:
		play("pistol_aiming_walking")

func _play_crouch(state: PlayerState) -> void:
	if state is CrouchingState:
		play("crouch_walking" if state.is_moving() else "crouch_idle")
	elif state is IdleState:
		play("crouch_idle")
	elif state is WalkingState:
		play("crouch_walking")

func _play_crouch_aim(state: PlayerState) -> void:
	if state is CrouchingState:
		play("crouch_walking" if state.is_moving() else "pistol_aiming_crouch")
	elif state is IdleState:
		play("pistol_aiming_crouch")
	elif state is WalkingState:
		play("crouch_walking")

func _play_cover_animation(state: CoverState, _is_aiming: bool) -> void:
	if state.is_snapping():
		play("stand_running")
		return
	if state.is_popping_up():
		play("pistol_aiming_idle")
		return
	if state.is_leaning():
		play("pistol_aiming_crouch" if state.is_low_cover() else "pistol_aiming_idle")
		return
	if state.is_moving_laterally():
		var going_right: bool = state.get_cover_direction() > 0.0
		if state.is_low_cover():
			play("crouch_cover_sneaking_left" if going_right else "crouch_cover_sneaking_right")
		else:
			play("stand_left_cover_sneak" if not going_right else "stand_right_cover_sneak")
		return
	play("idle_crouch_cover" if state.is_low_cover() else "stand_cover_idle")
