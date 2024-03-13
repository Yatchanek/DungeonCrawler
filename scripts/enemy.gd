extends CharacterBody2D
class_name Enemy

@export var attack_type : String = "Swing"
@export var unit_data : EnemyData

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pivot: Marker2D = $Pivot
@onready var fsm: FiniteStateMachine = $FSM
@onready var chase_stop_timer: Timer = $ChaseStopTimer
@onready var detector: Area2D = $Detector

@onready var exclamation_mark: Label = $ExclamationMark
@onready var ray_cast: RayCast2D = $RayCast

var sensor_shape: CollisionShape2D

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
	if has_node("AttackSensor"):
		sensor_shape = $AttackSensor/CollisionShape2D
	
	
func rotate_weapon():
	pass

func set_stats():
	current_damage = unit_data.base_damage
	current_hp = unit_data.base_hp
	max_speed = unit_data.base_speed
	acceleration = unit_data.acceleration
	friction = unit_data.friction
	if has_node("Pivot/WeaponPivot/Weapon"):
		$Pivot/WeaponPivot/Weapon.initialize_damage(current_damage)	
	
func attack() -> bool:
	return false

func take_damage(hit_by : HurtEntity):
	current_hp -= hit_by.current_damage
	if current_hp <= 0:
		is_dead = true
		queue_free()
	else:
		if hit_by is Trap:
			fsm.transition("HitState")
		elif check_if_player_in_sight():
			target = EnemyManager.player
			fsm.transition("HitState")
		if hit_by.has_knockback:
			knockback(hit_by)

func knockback(hit_by : HurtEntity):
	var direction : Vector2
	var force : float = min(hit_by.current_damage * 100, 200)
	direction = global_position.direction_to(hit_by.global_position) * -1
	velocity = direction * force
	fsm.transition("HitState")	

func disable_attack_sensor():
	sensor_shape.set_deferred("disabled", true)

func enable_attack_sensor():
	sensor_shape.set_deferred("disabled", false)

func _on_detector_body_entered(body: Node2D) -> void:
	if fsm.current_state.name == "IdleState":
		target = body
		fsm.transition("AlertState")

func _on_detector_body_exited(_body: Node2D) -> void:
	pass


func _on_attack_sensor_area_entered(_area : Area2D) -> void:
	pass


func _on_attack_cooldown_timer_timeout() -> void:
	pass


func _on_chase_stop_timer_timeout() -> void:
	pass

func check_if_player_in_sight() -> bool:
	if is_dead:
		return false
	if detector.get_overlapping_bodies().size() == 0:
		var state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
		var query : PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(global_position, EnemyManager.player.global_position, 17)
		var result : Dictionary = state.intersect_ray(query)
		if result and result.collider is Player:
			return true
		else:
			return false
	else:
		return true
