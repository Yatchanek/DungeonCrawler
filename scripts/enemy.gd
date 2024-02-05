extends CharacterBody2D

@export var attack_type : String = "Swing"
@export var unit_data : EnemyData

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pivot: Marker2D = $Pivot
@onready var fsm: FiniteStateMachine = $FSM
@onready var weapon: Weapon = $Pivot/WeaponPivot/Weapon
@onready var weapon_pivot: Marker2D = $Pivot/WeaponPivot
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var chase_stop_timer: Timer = $ChaseStopTimer
@onready var detector: Area2D = $Detector
@onready var sensor_shape: CollisionShape2D = $AttackSensor/CollisionShape2D

var target : CharacterBody2D

var current_damage : float
var current_hp : float
var is_dead : bool = false
var proximity_threshold : float
var max_speed : int
var acceleration : int
var friction : int

func _ready() -> void:
	set_stats()
	
func rotate_weapon():
	if is_instance_valid(target):
		weapon_pivot.look_at(target.global_position + Vector2(0, -20))

func set_stats():
	current_damage = unit_data.base_damage
	current_hp = unit_data.base_hp
	max_speed = unit_data.base_speed
	acceleration = unit_data.acceleration
	friction = unit_data.friction
	
	weapon.set_damage(current_damage)
	
	
func attack() -> bool:
	return weapon.attack(attack_type)

func take_damage(_weapon : Weapon, _knockback : bool = false):
	current_hp -= _weapon.current_damage
	if current_hp <= 0:
		is_dead = true
		queue_free()
	else:
		if check_if_player_in_sight(_weapon.user):
			target = _weapon.user
			fsm.transition("MoveState")
		if _knockback:
			knockback(_weapon)

func knockback(hit_by : Weapon):
	var direction : Vector2
	var force : float = min(hit_by.current_damage * 100, 200)
	if hit_by.is_launched:
		direction = global_position.direction_to(hit_by.global_position) * -1
		
	else:
		direction = global_position.direction_to(hit_by.user.global_position) * -1
	velocity = direction * force
	fsm.transition("HitState")	

func disable_attack_sensor():
	sensor_shape.set_deferred("disabled", true)

func enable_attack_sensor():
	sensor_shape.set_deferred("disabled", false)

func _on_detector_body_entered(body: Node2D) -> void:
	target = body
	fsm.transition("MoveState")

func _on_detector_body_exited(_body: Node2D) -> void:
	if !is_dead:
		chase_stop_timer.start()


func _on_attack_sensor_area_entered(area : Area2D) -> void:
	if area is HitBox:
		fsm.transition("AttackState")


func _on_attack_cooldown_timer_timeout() -> void:
	enable_attack_sensor()


func _on_chase_stop_timer_timeout() -> void:
	if check_if_player_in_sight(target):
		chase_stop_timer.start()
	else:
		target = null
		if fsm.current_state.name != "HitState":
			fsm.transition("IdleState")

func check_if_player_in_sight(_player) -> bool:
	if detector.get_overlapping_bodies().size() == 0:
		var state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
		var query : PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(global_position, _player.global_position, 17)
		var result : Dictionary = state.intersect_ray(query)
		if result and result.collider is Player:
			return true
	
		else:
			return false
	else:
		return true
