extends State

func enter_state(_prev_state : State) -> void:
	animator.play("Idle")
	
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
		transition.emit("MoveState")
	if actor.velocity != Vector2.ZERO:
		actor.velocity = actor.velocity.move_toward(Vector2.ZERO, actor.friction * delta)
		actor.move_and_slide()
