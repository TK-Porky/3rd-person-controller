extends Node
class_name GuardState

var guard: Guard
var state_machine: GuardStateMachine

func setup(g: Guard, sm: GuardStateMachine) -> void:
	guard = g
	state_machine = sm

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	pass
