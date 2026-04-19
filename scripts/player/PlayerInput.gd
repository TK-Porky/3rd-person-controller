extends RefCounted
class_name PlayerInput

var move_direction: Vector3 = Vector3.ZERO
var is_sprinting: bool = false
var is_crouching: bool = false
var jump_pressed: bool = false
var cover_pressed: bool = false
var aim_pressed: bool = false
var interact_pressed: bool = false
var shoot_pressed: bool = false

func update() -> void:
	var raw := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	move_direction = Vector3(raw.x, 0.0, raw.y)
	
	if Input.is_action_just_pressed("crouch"):
		is_crouching = not is_crouching
	if Input.is_action_just_pressed("jump"):
		is_crouching = false
	
	is_sprinting = Input.is_action_pressed("sprint")
	jump_pressed = Input.is_action_just_pressed("jump")
	cover_pressed = Input.is_action_just_pressed("cover")
	aim_pressed = Input.is_action_pressed("aim")
	interact_pressed = Input.is_action_just_pressed("interact")
	shoot_pressed = Input.is_action_just_pressed("shoot")

func cancel_crouch() -> void:
	is_crouching = false
