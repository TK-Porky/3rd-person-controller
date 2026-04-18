extends Area3D
class_name Interactable

signal interacted(interactable: Interactable)

@export var interaction_label := "Pickup"

var _outline_material: ShaderMaterial
var _is_highlighted := false
var _meshes: Array[MeshInstance3D] = []

func _ready() -> void:
	_collect_meshes(self)
	_setup_outline()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _collect_meshes(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			_meshes.append(child)
		if child.get_child_count() > 0:
			_collect_meshes(child)

func _setup_outline() -> void:
	_outline_material = ShaderMaterial.new()
	_outline_material.shader = preload("res://shaders/outline.gdshader")

func _on_body_entered(body: Node3D) -> void:
	if not body is Player: 
		return
	highlight(true)
	body.on_interactable_nearby(self)

func _on_body_exited(body: Node3D) -> void:
	if not body is Player:
		return
	highlight(false)
	body.on_interactable_left()

func highlight(active: bool) -> void:
	if active == _is_highlighted:
		return
	_is_highlighted = active
	
	for mesh in _meshes:
		if active:
			mesh.set_surface_override_material(0, _outline_material)
		else:
			mesh.set_surface_override_material(0, null)
		
func interact() -> void:
	interacted.emit(self)
	_on_interact()

func _on_interact() -> void:
	pass
