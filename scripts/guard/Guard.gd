extends CharacterBody3D
class_name Guard

# Exports
@export_category("Movement")
@export var move_speed: float = 3.5
@export var chase_speed: float = 6.0
@export var rotation_speed: float = 8.0

@export_category("Patrol")
@export var waypoint_path: NodePath

# Vars shared between states
var player_ref: Player = null
var last_known_player_pos: Vector3 = Vector3.ZERO
var waypoints: Array[Node3D] = []
var current_waypoint_index: int = 0

# Noeuds
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var vision_component: VisionComponent = $DetectionSystem/VisionComponent
@onready var hearing_component: HearingComponent = $DetectionSystem/HearingComponent
@onready var state_machine: GuardStateMachine = $GuardStateMachine
@onready var state_label: Label3D = $StateLabel
@onready var animator: GuardAnimator = %Animator

# Signals
signal player_spotted(player: Player)
signal player_lost
signal noise_heard(position: Vector3, intensity: float)

# Lifecycle
func _ready() -> void:
	await get_tree().physics_frame
	_load_waypoints()
	_connect_detection_signals()
	state_machine.initialize(self)

func _process(delta: float) -> void:
	state_machine.update(delta)
	animator.update_animation(self)

func _physics_process(delta: float) -> void:
	state_machine.physics_update(delta)
	move_and_slide()

# Connect Detection System
func _connect_detection_signals() -> void:
	vision_component.player_spotted.connect(_on_vision_spotted)
	vision_component.player_lost.connect(_on_vision_lost)
	hearing_component.noise_heard.connect(_on_hearing_noise)

func _on_vision_spotted(player: Player) -> void:
	if player_ref == player:
		return
	player_ref = player
	last_known_player_pos = player.global_position
	player_spotted.emit(player)

func _on_vision_lost() -> void:
	if not player_ref:
		return
	last_known_player_pos = player_ref.global_position
	player_ref = null
	player_lost.emit()

func _on_hearing_noise(noise_position: Vector3, intensity: float) -> void:
	if noise_position == Vector3.ZERO:
		return
	noise_heard.emit(noise_position, intensity)

# Actions
func rotate_body_toward(direction: Vector3) -> void:
	if direction.length_squared() < 0.01:
		return
	var target_basis := Basis.looking_at(-direction, Vector3.UP)
	global_transform.basis = global_transform.basis.slerp(
		target_basis,
		rotation_speed * get_physics_process_delta_time()
	)

func move_toward_target(target_pos: Vector3, speed: float) -> void:
	navigation_agent.target_position = target_pos

	if navigation_agent.is_navigation_finished():
		return

	var next_pos := navigation_agent.get_next_path_position()
	var dir := (next_pos - global_position).normalized()

	if dir.length_squared() < 0.001:
		return

	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

	rotate_body_toward(Vector3(dir.x, 0.0, dir.z))

func stop() -> void:
	velocity.x = 0.0
	velocity.z = 0.0

func is_nav_finished() -> bool:
	return navigation_agent.is_navigation_finished()

# Waypoints System Navigation
func _load_waypoints() -> void:
	if not waypoint_path:
		return
	var path_node := get_node(waypoint_path)
	if not path_node:
		return
	for child in path_node.get_children():
		if child is Node3D:
			waypoints.append(child)

func get_current_waypoint() -> Node3D:
	if waypoints.is_empty():
		return null
	return waypoints[current_waypoint_index]

func advance_waypoint() -> void:
	current_waypoint_index = (current_waypoint_index + 1) % waypoints.size()

# Debug
func update_state_label(txt: String) -> void:
	state_label.text = txt
