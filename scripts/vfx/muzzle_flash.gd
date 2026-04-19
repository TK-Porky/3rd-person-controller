extends Node3D
class_name MuzzleFlash

@onready var light: OmniLight3D = $OmniLight3D

const FLASH_DURATION := 0.05

var _timer := 0.0
var _active := false

func _ready() -> void:
	visible = false

func _process(delta: float) -> void:
	if not _active: return
	_timer -= delta
	if _timer <= 0.0:
		_active = false
		visible = false

func play() -> void:
	rotation.z = randf_range(0.0, TAU)
	visible = true
	_active = true
	_timer = FLASH_DURATION
