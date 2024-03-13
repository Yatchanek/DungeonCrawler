extends State

var turn_interval : float

func enter_state(_prev_state : State) -> void:
	actor.velocity = Vector2.ZERO
	animator.play("Idle")
	turn_interval = randf_range(2, 3)
	actor.target = null
	if is_instance_valid(actor.ray_cast):
		actor.ray_cast.enabled = true

func exit_state():
	actor.ray_cast.enabled = false
	
func frame_update(delta):
	turn_interval -= delta
	if turn_interval <= 0:
		pivot.scale.x *= -1
		turn_interval = randf_range(2, 3)
		
	if pivot.global_transform.x.dot(actor.global_position.direction_to(EnemyManager.player.global_position)) > 0:
		actor.ray_cast.target_position = actor.to_local(EnemyManager.player.global_position)
		
		if actor.ray_cast.is_colliding():
			if actor.ray_cast.get_collider() is Player:
				actor.target =  actor.ray_cast.get_collider() 
				transition.emit("AlertState")
	
