extends CharacterBody3D
class_name Player

# Player Physics
@export_category("Movement")
@export var move_speed := 3.0
@export var sprint_speed := 5.0
@export var acceleration := 5.0
@export var jump_impusle := 8.0
@export var gravity_multiplier := 1.0
@export var rotation_speed := 12.0

@export_category("Crouch")
@export var normal_height := 2.0
@export var crouch_height := 1.0
@export var crouch_speed := 2.0
@export var crouch_transition_speed := 0.2

@export_category("Cover")
@export var cover_move_speed := 3.0
@export var cover_snap_speed := 8.0

# Shared between States 
var input: PlayerInput
var last_move_direction := Vector3.BACK

var _nearby_interactable : Interactable = null

# Nodes
@onready var movement_sm: PlayerStateMachine = %MovementStateMachine
@onready var action_sm: PlayerStateMachine = %ActionStateMachine
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var skin: Animator = %Skin
@onready var hud: HUD = $HUD

# Controllers & Managers
@onready var camera_controller: CameraController = %CameraController
@onready var weapon_manager: WeaponManager = $WeaponManager
@onready var vfx_manager: VFXManager = $VFXManager

# Sensors
@onready var sensors: Node3D = $Sensors
@onready var body_detector: RayCast3D = %BodyDetector
@onready var body_detector_left: RayCast3D = %BodyDetectorLeft
@onready var body_detector_right: RayCast3D = %BodyDetectorRight
@onready var head_detector: RayCast3D = %HeadDetector
@onready var top_detector: RayCast3D = %TopDetector

# Game Physics
const GRAVITY: float = -36.0

func _ready() -> void:
	add_to_group("player")
	input = PlayerInput.new()
	movement_sm.initialize(self)
	action_sm.initialize(self)
	_setup_debug()

func _setup_debug() -> void:
	var panel: DebugPanel = get_node_or_null("HUD/MarginContainer/DebugPanel")
	if not panel: return
	
	panel.register("movement state", func(): return movement_sm.current_state.name)
	panel.register("action state", func(): return action_sm.current_state.name)
	panel.register("velocity", func(): return velocity)
	panel.register("speed_xz", func(): return Vector3(velocity.x, 0.0, velocity.z))
	panel.register("grounded", func(): return is_on_floor())
	panel.register("near_cover", func(): return is_near_cover())
	panel.register("move_input", func(): return input.move_direction)
	panel.register("sprint", func(): return input.is_sprinting)

func _unhandled_input(event: InputEvent) -> void:
	camera_controller.handle_mouse_input(event)

func _process(delta: float) -> void:
	input.update()
	movement_sm.update(delta)
	action_sm.update(delta)
	skin.update_animation(self)
	if weapon_manager.has_weapon():
		hud.show_weapon_display()
		hud.update_ammo(weapon_manager.current_ammo, weapon_manager.reserve_ammo)
	else:
		hud.hide_weapon_display()

func _physics_process(delta: float) -> void:
	movement_sm.physics_update(delta)
	action_sm.physics_update(delta)
	camera_controller.update(global_position, delta)

func is_near_cover() -> bool:
	if not is_on_floor(): return false
	if not body_detector.is_colliding(): return false
	return true

func is_aiming() -> bool:
	return action_sm.current_state is AimingState

func is_grounded() -> bool:
	return is_on_floor()

func is_firing() -> bool:
	return action_sm.current_state is FiringState

func is_reloading() -> bool:
	return action_sm.current_state is ReloadingState

func get_gravity_force() -> float:
	return GRAVITY * gravity_multiplier

#  Actions
func apply_movement(direction: Vector3, speed: float, delta: float) -> void:
	velocity = velocity.move_toward(direction * speed, acceleration * delta)
	if direction.length() > 0.2:
		last_move_direction = direction
	move_and_slide()

func rotate_toward(target_direction: Vector3, delta: float) -> void:
	if target_direction.length() < 0.1: return
	var target_angle = Vector3.BACK.signed_angle_to(target_direction, Vector3.UP)
	var current_angle := skin.global_transform.basis.get_euler().y
	var new_angle := lerp_angle(current_angle, target_angle, rotation_speed * delta)
	skin.rotation.y = new_angle
	sensors.rotation.y = new_angle + PI

func apply_gravity(delta: float) -> void:
	if is_grounded() and velocity.y <= 0.0:
		velocity.y = -0.1
		return
	velocity.y += get_gravity_force() * delta

func apply_jump() -> void:
	velocity.y = jump_impusle

func reset_vertical_velocity() -> void:
	velocity.y = 0.0

func rotate_sensors(angle: float) -> void:
	sensors.rotation.y = angle

func cancel_crouch() -> void:
	input.cancel_crouch()

func on_interactable_nearby(interactable: Interactable) -> void:
	_nearby_interactable = interactable
	hud.show_interaction_prompt(interactable.interaction_label)

func on_interactable_left() -> void:
	_nearby_interactable = null
	hud.hide_interaction_prompt()

func try_interact() -> void:
	if _nearby_interactable:
		_nearby_interactable.interact()

func set_collision_height(height: float) -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(collision_shape.shape, "height", height, crouch_transition_speed)
	tween.tween_property(collision_shape, "position:y", height/2, crouch_transition_speed)
