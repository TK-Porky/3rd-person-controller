extends Node3D
class_name VisionComponent

signal player_spotted(player: Player)
signal player_lost

@export var fov_angle: float = 45.0
@export var vision_range: float = 15.0
@export var peripheral_range: float = 5.0

@onready var raycast: RayCast3D = $RayCast3D
@export var activation_delay: float = 0.5

var _player: Player = null
var _is_player_visible: bool = false
var _is_active: bool = false

func _ready() -> void:
	await get_tree().create_timer(activation_delay).timeout
	_is_active = true

func _physics_process(_delta: float) -> void:
	if not _is_active:
		return
	_check_vision()

func _check_vision() -> void:
	var player := _get_player()
	if player == null:
		return

	var to_player := player.global_position - global_position
	var distance := to_player.length()

	if distance > vision_range:
		_handle_loss()
		return

	var dir_to_player := to_player.normalized()
	var forward := -global_transform.basis.z.normalized()
	var dot := forward.dot(dir_to_player)
	var angle := rad_to_deg(acos(clamp(dot, -1.0, 1.0)))

	if angle > fov_angle:
		if distance > peripheral_range:
			_handle_loss()
			return

	raycast.target_position = raycast.to_local(player.global_position)
	raycast.force_raycast_update()

	if raycast.is_colliding():
		var collider := raycast.get_collider()
		if collider == player:
			_handle_spot(player)
		else:
			_handle_loss()
	else:
		_handle_loss()

func _handle_spot(player: Player) -> void:
	if not _is_player_visible:
		_is_player_visible = true
		_player = player
		emit_signal("player_spotted", player)

func _handle_loss() -> void:
	if _is_player_visible:
		_is_player_visible = false
		_player = null
		emit_signal("player_lost")

func _get_player() -> Player:
	if _player:
		return _player
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	_player = players[0] as Player
	return _player
