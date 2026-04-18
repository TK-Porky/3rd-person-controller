extends Node
class_name PlayerStateMachine

@export var initial_state: PlayerState

var current_state: PlayerState
var player: Player

func initialize(p: Player) -> void:
	player = p
	for child in get_children():
		if child is PlayerState:
			child.setup(player, self)
	
	current_state = initial_state
	current_state.enter()

func transition_to(new_state: PlayerState) -> void:
	if new_state == current_state: return
	current_state.exit()
	current_state = new_state
	current_state.enter()

func update(delta: float) -> void:
	current_state.update(delta)
	
func physics_update(delta: float) -> void:
	current_state.physics_update(delta)
