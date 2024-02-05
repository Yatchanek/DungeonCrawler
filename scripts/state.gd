extends Node
class_name State

var previous_state : State
var is_current : bool = false

signal transition(new_state : String)

var actor : CharacterBody2D
var animator : AnimationPlayer
var pivot : Marker2D
var context_steering_component : ContextSteeringComponent

@onready var state_machine : FiniteStateMachine = get_parent()

func enter_state(_prev_state : State) -> void:
	pass
	
func exit_state() -> void:
	pass
	
func frame_update(_delta : float) -> void:
	pass
	
func physics_update(_delta : float) -> void:
	pass

func animation_finished(_anim_name : String) -> void:
	pass

