extends State

@export var cooldown_timer : Timer

func enter_state(_prev_state : State) -> void:
	animator.play("RESET")
	previous_state = _prev_state
	actor.velocity = Vector2.ZERO
	actor.attack()
	#	transition.emit("MoveState")
		
	
func animation_finished(anim_name : String) -> void:
	if anim_name == "Cast":
		transition.emit("MoveState")
		
