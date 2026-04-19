extends Node
class_name WeaponManager

@export var weapon_attachment: BoneAttachment3D

var current_weapon: WeaponData = null
var current_weapon_instance: Node3D = null

var _player: Player

func _ready() -> void:
	_player = get_parent() as Player

func equip(weapon_data: WeaponData) -> void:
	if current_weapon != null:
		_drop_current_weapon()
	
	current_weapon = weapon_data
	print(current_weapon)
	_spawn_weapon_in_hand()

func drop() -> void:
	if current_weapon == null:
		return
	_drop_current_weapon()
	current_weapon = null

func has_weapon() -> bool:
	return current_weapon != null

func _spawn_weapon_in_hand() -> void:
	if current_weapon.scene == null: return
	
	current_weapon_instance = current_weapon.scene.instantiate()
	weapon_attachment.add_child(current_weapon_instance)
	
	current_weapon_instance.position = current_weapon.position_offset
	current_weapon_instance.rotation_degrees = current_weapon.rotation_offset
	
	var muzzle_point := current_weapon_instance.get_node_or_null("MuzzlePoint")
	if muzzle_point:
		_player.vfx_manager.initialize(muzzle_point)

func _drop_current_weapon() -> void:
	if current_weapon.scene == null:
		return
	
	var pickup_scene := load(current_weapon.pickup_scene_path)
	if pickup_scene:
		var pickup = pickup_scene.instantiate()
		get_tree().current_scene.add_child(pickup)
		pickup.global_position = weapon_attachment.global_position
		pickup.global_position.y = _get_floor_y()
	
	if current_weapon_instance:
		current_weapon_instance.queue_free()
		current_weapon_instance = null

func _get_floor_y() -> float:
	var player := get_parent()
	return player.global_position.y
