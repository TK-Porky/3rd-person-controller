extends Area3D
class_name HearingComponent

signal noise_heard(position: Vector3, intensity: float)

@export var hearing_range: float = 10.0

@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_update_range()

func _update_range() -> void:
	var sphere := SphereShape3D.new()
	sphere.radius = hearing_range
	collision_shape.shape = sphere

func receive_noise(pos: Vector3, intensity: float) -> void:
	emit_signal("noise_heard", pos, intensity)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var player := body as Player
		if player.input.is_sprinting:
			emit_signal("noise_heard", player.global_position, 1.0)
		if player.movement_sm.current_state is WalkingState:
			emit_signal("noise_heard", player.global_position, 1.0)
		if player.pistol_shoot.playing:
			emit_signal("noise_heard", player.global_position, 1.0)
