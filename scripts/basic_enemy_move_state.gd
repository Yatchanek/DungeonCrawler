extends State

@export var cooldown_timer : Timer

func enter_state(_prev_state : State) -> void:
	animator.play("Move")
	if cooldown_timer.is_stopped():
		actor.enable_attack_sensor()
	actor.weapon.show()

func frame_update(_delta : float) -> void:
	actor.rotate_weapon()

func physics_update(delta : float) -> void:
	if is_instance_valid(actor.target):
		var direction_to_target : Vector2 = actor.global_position.direction_to(actor.target.global_position + Vector2(0, -20))
		var dist_to_target : float = actor.global_position.distance_squared_to(actor.target.global_position)
		

		var new_dir = context_steering_component.get_context_steering(direction_to_target)
		var desired_velocity : Vector2 = new_dir * actor.max_speed
		
		if dist_to_target < actor.unit_data.proximity_threshold * actor.unit_data.proximity_threshold * 0.75:
			desired_velocity *= -1
		elif dist_to_target < actor.unit_data.proximity_threshold * actor.unit_data.proximity_threshold * 1.05:
			desired_velocity = Vector2.ZERO

		
		if new_dir.x < 0:
			pivot.scale.x = -1
		else:
			pivot.scale.x = 1
		if desired_velocity == Vector2.ZERO:
			actor.velocity = actor.velocity.move_toward(desired_velocity, actor.friction * delta)	
		else:
			actor.velocity = actor.velocity.move_toward(desired_velocity, actor.acceleration * delta)
	else:
		transition.emit("IdleState")
	
	actor.move_and_slide()
