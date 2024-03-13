extends Enemy

var explosion_scene = preload("res://scenes/explosion.tscn")

@onready var detector_collision: CollisionShape2D = $Detector/CollisionShape2D
@onready var attack_sensor: Area2D = $AttackSensor
	
func _on_detector_body_exited(_body) -> void:
	if !is_dead:
		chase_stop_timer.start()

func _on_attack_sensor_area_entered(area : Area2D) -> void:
	if area is HitBox:
		fsm.transition("ExplodeState")
		
func _on_attack_cooldown_timer_timeout() -> void:
	enable_attack_sensor()

func _on_chase_stop_timer_timeout() -> void:
	if is_dead:
		return
	if check_if_player_in_sight(target):
		chase_stop_timer.start()
	else:
		target = null
		if fsm.current_state.name != "HitState":
			fsm.transition("IdleState")

func explode():
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = CircleShape2D.new() as CircleShape2D
	query.shape.radius = 72
	query.transform.origin = global_transform.origin
	query.collision_mask = 5
	var state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var result = state.intersect_shape(query)
	if result:
		for hit in result:
			hit.collider.take_damage(self, true)
		
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_parent().get_parent().call_deferred("add_child", explosion)
	is_dead = true
	queue_free()
