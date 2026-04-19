extends Node
class_name VFXManager

@export var impact_effect: PackedScene
@export var muzzle_flash_scene: PackedScene
@export var _weapon_ray: RayCast3D

var _muzzle_flash: MuzzleFlash = null
var _player: Player

func _ready() -> void:
	_player = get_parent() as Player

func initialize(muzzle_point: Node3D) -> void:
	if not muzzle_flash_scene: return
	_muzzle_flash = muzzle_flash_scene.instantiate()
	muzzle_point.add_child(_muzzle_flash)

func spawn_muzzle_flash() -> void:
	if _muzzle_flash:
		_muzzle_flash.play()

# Too Complex to Explain TwT - Just don't touch it
func spawn_impact(position: Vector3, normal: Vector3) -> void:
	if not impact_effect: return
	var effect := impact_effect.instantiate()
	get_tree().current_scene.add_child(effect)

	effect.global_position = position + normal * 0.01
	var decal_transform := Transform3D()

	if abs(normal.dot(Vector3.UP)) > 0.9:
		decal_transform = decal_transform.looking_at(position + normal, Vector3.FORWARD)
	else:
		decal_transform = decal_transform.looking_at(position + normal, Vector3.UP)

	effect.global_transform.basis = decal_transform.basis.rotated( decal_transform.basis.x, -PI / 2.0)
	effect.global_position = position + normal * 0.01

func get_weapon_raycast() -> RayCast3D:
	return _weapon_ray
	
func get_weapon_muzzle_position() -> Vector3:
	if _muzzle_flash:
		return _muzzle_flash.global_position
	return _player.global_position
