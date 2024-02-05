extends State

@export var cooldown_timer : Timer

func enter_state(_prev_state : State) -> void:
	previous_state = _prev_state
	actor.velocity = Vector2.ZERO
	if actor.attack():
		actor.disable_attack_sensor()
	else:
		actor.disable_attack_sensor()
		transition.emit("MoveState")
		cooldown_timer.start(0.15)
	
func animation_finished(anim_name : String) -> void:
	if anim_name == "Swing" or anim_name == "Thrust":
		cooldown_timer.start(1.0)
		transition.emit("MoveState")
		
