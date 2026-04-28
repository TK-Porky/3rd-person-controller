extends GuardState
class_name AlertState

@export var alert_duration := 2.0
var _timer := 0.0

func _enter() -> void:
	print(guard.name, " entering ", name)
	guard.player_spotted.connect(_on_player_spotted)
	guard.update_state_label(name.to_pascal_case())
	_timer = 0.0
	guard.velocity = Vector3.ZERO

func exit() -> void:
	guard.player_spotted.disconnect(_on_player_spotted)

func update(delta: float) -> void:
	_timer += delta
	if _timer >= alert_duration:
		if guard.player_ref != null:
			state_machine.transition_to(state_machine.alert)
		else:
			state_machine.transition_to(state_machine.search)

func physics_update(_delta: float) -> void:
	if guard.last_known_player_pos != Vector3.ZERO:
		var dir := (guard.last_known_player_pos - guard.global_position).normalized()
		guard.rotate_body_toward(dir)

func _on_player_spotted(_player: Player) -> void:
	state_machine.transition_to(state_machine.chase)
