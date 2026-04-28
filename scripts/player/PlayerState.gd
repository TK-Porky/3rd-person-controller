extends Node
class_name PlayerState

var player: Player
var state_machine: PlayerStateMachine

func setup(p: Player, sm: PlayerStateMachine) -> void:
	player = p
	state_machine = sm

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	pass

func orient_player_skin(normal: Vector3) -> void:
	# On définit la direction vers laquelle le skin doit regarder
	# -normal pour faire face au mur / normal pour lui tourner le dos
	var look_direction := -normal 
	
	# On calcule le point cible à regarder (à la même hauteur que le joueur)
	var target_look = player.global_position + look_direction
	target_look.y = player.global_position.y
	
	# On oriente le skin (ton mesh 3D)
	player.skin.look_at(target_look, Vector3.UP)

func orient_detectors(normal: Vector3) -> void:
	# On calcule la direction vers le mur
	var forward_dir = -normal
	
	# On utilise look_at sur le pivot qui contient tes Raycasts
	var pivot = player.raycasts
	var target_pos = pivot.global_position + forward_dir
	
	pivot.look_at(target_pos, Vector3.UP)
