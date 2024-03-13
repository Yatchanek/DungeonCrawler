extends State

func enter_state(_prev_state : State) -> void:
	actor.velocity = Vector2.ZERO
	actor.disable_attack_sensor()
	actor.detector_collision.set_deferred("disabled", true)
	animator.speed_scale = 2.0
	animator.play("Explode")
