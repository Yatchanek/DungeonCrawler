extends State

var duration : float

func enter_state(_prev_state : State) -> void:
	actor.velocity = Vector2.ZERO
	duration = 0
	actor.exclamation_mark.show()
		
func exit_state() -> void:
	actor.exclamation_mark.hide()
	
func frame_update(delta):
	duration += delta
	if duration > 0.5:
		transition.emit("MoveState")
