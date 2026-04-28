extends GuardState
class_name AttackState

@export var attack_range: float = 8.0
@export var fire_rate: float = 1.5
var _fire_timer: float = 0.0

func enter() -> void:
	guard.player_lost.connect(_on_player_lost)
	guard.update_state_label(name.to_pascal_case())
	_fire_timer = 0.0
	guard.velocity = Vector3.ZERO

func exit() -> void:
	guard.player_lost.disconnect(_on_player_lost)

func update(delta: float) -> void:
	if guard.player_ref == null:
		state_machine.transition_to(state_machine.search)
		return

	var dist := guard.global_position.distance_to(guard.player_ref.global_position)

	if dist > attack_range:
		state_machine.transition_to(state_machine.chase)
		return

	_fire_timer += delta
	if _fire_timer >= fire_rate:
		_fire_timer = 0.0
		_shoot()

func physics_update(_delta: float) -> void:
	if guard.player_ref == null:
		return
	var dir := (guard.player_ref.global_position - guard.global_position).normalized()
	guard.rotate_body_toward(dir)

func _shoot() -> void:
	# TODO: Connecter au système d'arme du garde
	pass

func _on_player_lost() -> void:
	state_machine.transition_to(state_machine.search)
