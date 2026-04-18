extends Node
class_name LeanComponent

@export var lean_pitch_max := 0.08
@export var lean_roll_max := 0.06
@export var lean_speed := 8.0

var _previous_velocity := Vector3.ZERO

@export var player: Player
@export var skin: Node3D

func update(delta: float) -> void:
	var horizontal_velocity := Vector3(player.velocity.x, 0.0, player.velocity.z)
	var ground_speed := horizontal_velocity.length()
	var max_speed := player.sprint_speed
	
	var pitch_target := (ground_speed / max_speed) * lean_pitch_max
	
	var velocity_delta := player.velocity - _previous_velocity
	var lateral_accel := velocity_delta / delta
	
	var skin_right := skin.global_basis.x
	var lateral_force := lateral_accel.dot(skin_right)
	
	var roll_target: float = clamp(-lateral_force / (max_speed * 10.0), -lean_roll_max, lean_roll_max)
	
	skin.rotation.x = lerp_angle(skin.rotation.x, pitch_target, lean_speed * delta)
	skin.rotation.y = lerp_angle(skin.rotation.z, roll_target, lean_speed * delta)
	
	_previous_velocity = player.velocity
	
func reset(delta: float) -> void:
	skin.rotation.x = lerp_angle(skin.rotation.x, 0.0, lean_speed * delta)
	skin.rotation.z = lerp_angle(skin.rotation.z, 0.0, lean_speed * delta)
