extends Interactable
class_name WeaponPickup

@export var weapon_data: WeaponData

func _ready() -> void:
	super._ready()
	print(weapon_data)
	if weapon_data:
		interaction_label = "Pickup " + weapon_data.weapon_name

func _on_interact() -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	player.weapon_manager.equip(weapon_data)
	player.pistol_reload.play(1.5)
	print(weapon_data)
	queue_free()
