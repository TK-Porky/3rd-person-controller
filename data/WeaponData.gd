extends Resource
class_name WeaponData

@export var weapon_name: String = ""
@export var scene: PackedScene
@export var pickup_scene_path: String = ""

@export_category("Fire Mode")
@export var is_automatic: bool = false
@export var fire_rate: float = 0.2
@export var magazine_size: int = 15
@export var reserve_ammo: int = 60
@export var damage: float = 25.0

@export_category("Hand Position")
@export var position_offset: Vector3 = Vector3.ZERO
@export var rotation_offset: Vector3 = Vector3.ZERO
