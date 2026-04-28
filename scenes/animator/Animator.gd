extends Node3D
class_name Animator

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func update_animation(_entity: CharacterBody3D) -> void:
	pass

func play(anim_name: String) -> void:
	if anim_player.current_animation == anim_name:
		return
	anim_player.play(anim_name)
