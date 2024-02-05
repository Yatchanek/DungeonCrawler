extends State

func enter_state(_prev_state : State) -> void:
	previous_state = _prev_state
	animator.play("Hit")

	
func physics_update(_delta : float) -> void:
	actor.move_and_slide()

func animation_finished(anim_name : String) -> void:
	if anim_name == "Hit":
		transition.emit("MoveState")
