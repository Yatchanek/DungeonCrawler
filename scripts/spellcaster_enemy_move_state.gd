extends State

@export var cooldown_timer : Timer

var spellcast_frequency : float = 1.5
var can_cast : bool = false

func enter_state(_prev_state : State) -> void:
	can_cast = false
	spellcast_frequency = 1.5
	animator.play("Move")
	actor.weapon.show()

func physics_update(delta : float) -> void:
	spellcast_frequency -= delta
	if spellcast_frequency <= 0:
		can_cast = true
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
		
		if actor.player_in_range and can_cast:
			transition.emit("AttackState")
	
	else:
		transition.emit("IdleState")
	
	actor.move_and_slide()
