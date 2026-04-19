extends CanvasLayer
class_name HUD

@onready var debug_panel: DebugPanel = $MarginContainer/DebugPanel
@onready var crosshair: Panel = $Crosshair
@onready var interaction_prompt: Label = %InteractionPrompt
@onready var interaction_container: HBoxContainer = $InteractionContainer
@onready var weapon_display_container: PanelContainer = $WeaponDisplayContainer
@onready var ammo_label: Label = %AmmoDisplay

func _ready() -> void:
	interaction_container.hide()

func show_weapon_display() -> void:
	weapon_display_container.show()

func hide_weapon_display() -> void:
	weapon_display_container.hide()

func update_ammo(current: int, reserve: int) -> void:
	ammo_label.text = "%d / %d" % [current, reserve]

func show_interaction_prompt(label: String) -> void:
	interaction_prompt.text = label
	interaction_container.show()

func hide_interaction_prompt() -> void:
	interaction_container.hide()

func hide_crosshair() -> void:
	crosshair.hide()

func show_crosshair() -> void:
	crosshair.show()
