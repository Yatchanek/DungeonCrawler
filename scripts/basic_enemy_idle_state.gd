extends State

func enter_state(_prev_state : State) -> void:
	actor.velocity = Vector2.ZERO
	animator.play("Idle")
	if is_instance_valid(actor.weapon):
		actor.weapon.hide()

