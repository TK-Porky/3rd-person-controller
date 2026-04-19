extends Node
class_name PlayerStateMachine

@export var initial_state: PlayerState

var current_state: PlayerState
var previous_state: PlayerState = null
var next_state: PlayerState = null

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
	next_state = new_state
	current_state.exit()
	previous_state = current_state
	current_state = new_state
	next_state = null
	current_state.enter()

func update(delta: float) -> void:
	current_state.update(delta)
	
func physics_update(delta: float) -> void:
	current_state.physics_update(delta)
