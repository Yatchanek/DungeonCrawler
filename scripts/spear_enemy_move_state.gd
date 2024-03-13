extends State

@export var cooldown_timer : Timer

var can_throw : bool
var throw_interval : float

func enter_state(_prev_state : State) -> void:
	can_throw = false
	throw_interval = 1.0
	animator.play("Move")
	if cooldown_timer.is_stopped():
		actor.enable_attack_sensor()
	actor.weapon.show()

func frame_update(delta : float) -> void:
	throw_interval -= delta
	if throw_interval <= 0:
		can_throw = true
		
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
		elif dist_to_target > actor.unit_data.proximity_threshold * actor.unit_data.proximity_threshold * 4:
			if can_throw and randf() < 0.1:
				can_throw = false
				throw_interval = 1.5
				actor.weapon.launch()
		
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
	#actor.queue_redraw()
	actor.move_and_slide()
