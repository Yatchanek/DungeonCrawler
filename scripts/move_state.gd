extends State

func enter_state(_prev_state : State) -> void:
	animator.play("Move")

func exit_state() -> void:
	animator.speed_scale = 1

func frame_update(_delta : float) -> void:
	actor.rotate_weapon()
	if Input.is_action_just_pressed("attack"):
		actor.attack()
	elif Input.is_action_just_pressed("attack2"):
		actor.charge_weapon_start()
	elif Input.is_action_just_released("attack2"):
		actor.throw_weapon()
	
func physics_update(delta : float) -> void:
	var direction : Vector2 = actor.get_input()
	if direction != Vector2.ZERO:
		var speed : float = actor.max_speed
		if sign(direction.x) == -sign(pivot.scale.x):
			speed = actor.max_speed * 0.5
			animator.speed_scale = -1
		else:
			animator.speed_scale = 1
				
		actor.velocity = actor.velocity.move_toward(direction * speed, actor.acceleration * delta)	

	else:
		actor.velocity = actor.velocity.move_toward(Vector2.ZERO, actor.friction * delta)
	
	actor.move_and_slide()
	
	if actor.velocity == Vector2.ZERO:
		transition.emit("IdleState")
	
		
		
