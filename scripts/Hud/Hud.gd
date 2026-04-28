extends CanvasLayer
class_name HUD

@onready var debug_panel: DebugPanel = $MarginContainer/DebugPanel
@onready var crosshair: Panel = $Crosshair
@onready var interaction_prompt: Label = %InteractionPrompt
@onready var interaction_container: HBoxContainer = $InteractionContainer
@onready var weapon_display_container: PanelContainer = $WeaponDisplayContainer
@onready var ammo_label: Label = %AmmoDisplay
@onready var document_screen: DocumentScreen = %DocumentScreen
@onready var notification_display_container: PanelContainer = $NotificationDisplayContainer
@onready var notification_prompt: Label = %NotificationLabel

var _notification_timer := 0.0
var current_interactable: Node3D = null

const NOTIFICATION_DURATION := 3.0

@onready var camera = get_viewport().get_camera_3d()

func _ready() -> void:
	hide_document_screen()
	hide_interaction_prompt()
	hide_notification()

func _process(delta: float) -> void:
	if _notification_timer > 0.0:
		_notification_timer -= delta
		if _notification_timer <= 0.0:
			hide_notification()
	
	if current_interactable == null:
		return
	
	if camera.is_position_behind(current_interactable.global_position):
		interaction_container.visible = false
		return

	interaction_container.visible = true

	var world_pos = current_interactable.global_position + Vector3(0, 0.1, 0)
	var screen_pos = camera.unproject_position(world_pos)
	
	interaction_container.global_position = screen_pos - interaction_container.size / 2.0

# === WEAPON
func show_weapon_display() -> void:
	weapon_display_container.show()

func hide_weapon_display() -> void:
	weapon_display_container.hide()

func update_ammo(current: int, reserve: int) -> void:
	ammo_label.text = "%d / %d" % [current, reserve]

# === INTERACTION PROMPT
func show_interaction_prompt(target: Node3D, label: String) -> void:
	current_interactable = target
	interaction_prompt.text = label
	interaction_container.show()

func hide_interaction_prompt() -> void:
	current_interactable = null
	interaction_container.hide()

# === NOTIFICATION
func show_notification(text: String) -> void:
	notification_display_container.show()
	notification_prompt.text = "Current Objective: \n" + text
	_notification_timer = NOTIFICATION_DURATION

func hide_notification() -> void:
	notification_display_container.hide()

# === CROSSHAIR
func hide_crosshair() -> void:
	crosshair.hide()

func show_crosshair() -> void:
	crosshair.show()

# === DOCUMENT VIEWER
func show_document_screen() -> void:
	document_screen.show()

func hide_document_screen() -> void:
	document_screen.hide()

func get_document_screen() -> DocumentScreen:
	return document_screen
