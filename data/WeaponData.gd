extends Resource
class_name WeaponData

@export var weapon_name: String = ""
@export var scene: PackedScene
@export var pickup_scene_path: String = ""

@export_category("Hand Position")
@export var position_offset: Vector3 = Vector3.ZERO
@export var rotation_offset: Vector3 = Vector3.ZERO
