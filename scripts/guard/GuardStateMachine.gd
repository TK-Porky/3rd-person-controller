extends Node
class_name GuardStateMachine

@export var initial_state: GuardState
var current_state: GuardState
var next_state: GuardState
var previous_state: GuardState

var guard: Guard

# States
@onready var patrol: PatrolState = $Patrol
@onready var alert: AlertState = $Alert
@onready var chase: ChaseState = $Chase
@onready var search: SearchState = $Search
@onready var attack: AttackState = $Attack

func initialize(g: Guard) -> void:
	guard = g
	for child in get_children():
		if child is GuardState:
			child.setup(guard, self)
	
	current_state = initial_state
	current_state.enter()

func transition_to(new_state: GuardState) -> void:
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
	#print("Guard-FSM: Physics Process Running...")
