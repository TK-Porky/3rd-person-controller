extends Node3D
class_name CameraController

@export_category("Sensitivity")
@export var mouse_sensitivity := 0.25

@export_category("Pitch Limits")
@export var pitch_min := -30.0
@export var pitch_max := 60.0

@export_category("Shoulder")
@export var shoulder_offset := 0.4
@export var shoulder_swap_speed := 8.0

@export_category("Arm Length")
@export var default_length := 1.0
@export var crouch_length := 1.5
@export var aim_length := 0.5
@export var crouch_aim_length := 0.8
@export var length_change_speed := 7.0

@export_category("Follow")
@export var default_height  := 1.25
@export var crouch_height  := 0.75 
@export var follow_speed   := 15.0
@export var height_change_speed := 8.0

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D = $SpringArm3D/Camera3D

enum CameraSide { RIGHT, LEFT }
var _side: CameraSide = CameraSide.RIGHT
var _current_side_sign := 1.0 

var _pitch: float = 0.0
var _yaw: float = 0.0
var _mouse_delta: Vector2 = Vector2.ZERO

var _is_swapping_active : bool = false
var _is_aiming: bool = false
var _is_crouching: bool = false

var _target_length: float
var _current_height: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_as_top_level(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_target_length = default_length
	_current_height = default_height

func handle_mouse_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE and event.is_pressed():
		_swap_shoulder()
	
	if event.is_action_pressed("ui_cancel") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_delta = event.relative

func update(player_position: Vector3, delta: float) -> void:
	_update_rotation(delta)
	_update_follow(player_position, delta)
	_update_shoulder(delta)
	_update_arm_length(delta)

func _update_rotation(delta: float) -> void:
	_yaw   -= _mouse_delta.x * mouse_sensitivity * delta
	_pitch -= _mouse_delta.y * mouse_sensitivity * delta
	_pitch  = clamp(_pitch, deg_to_rad(pitch_min), deg_to_rad(pitch_max))
	_mouse_delta = Vector2.ZERO
	rotation = Vector3(_pitch, _yaw, 0.0)

func _update_follow(player_position: Vector3, delta: float) -> void:
	var target_height := crouch_height if _is_crouching else default_height
	_current_height = lerp(_current_height, target_height, height_change_speed * delta)
	
	var target := player_position + Vector3.UP * _current_height
	global_position = global_position.lerp(target, follow_speed * delta)

func _update_shoulder(delta: float) -> void:
	var target_x := _current_side_sign * shoulder_offset
	spring_arm.position.x = lerp(spring_arm.position.x, target_x, shoulder_swap_speed * delta)

func _update_arm_length(delta: float) -> void:
	var target_length := _resolve_arm_length()
	spring_arm.spring_length = lerp(
		spring_arm.spring_length,
		target_length,
		length_change_speed * delta
	)

func _resolve_arm_length() -> float:
	if _is_crouching and _is_aiming:    
		return crouch_aim_length
	if _is_aiming:
		return aim_length
	if _is_crouching:                   
		return crouch_length
	return default_length

func enter_aim_mode() -> void:
	_is_aiming = true

func exit_aim_mode() -> void:
	_is_aiming = false

func enter_crouch_mode() -> void:
	_is_crouching = true

func exit_crouch_mode() -> void:
	_is_crouching = false

func get_camera_basis() -> Basis:
	return spring_arm.global_transform.basis

func get_yaw() -> float:
	return _yaw

func _swap_shoulder() -> void:
	_is_swapping_active = not _is_swapping_active
	
	_side = CameraSide.LEFT if not _is_swapping_active else CameraSide.RIGHT
	_current_side_sign = 1.0 if not _is_swapping_active else -1.0
