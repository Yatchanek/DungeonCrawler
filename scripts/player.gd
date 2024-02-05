extends CharacterBody2D
class_name Player

@onready var weapon_pivot: Marker2D = $Pivot/WeaponPivot
@onready var weapon: Weapon = $Pivot/WeaponPivot/Weapon
@onready var body: Sprite2D = $Pivot/Body
@onready var anim_player : AnimationPlayer  = $AnimationPlayer
@onready var pivot : Marker2D = $Pivot
@onready var weapon_charge_timer: Timer = $WeaponChargeTimer
@onready var fsm: FiniteStateMachine = $FSM

@export var Stats : StatsData

const CHARGE_THRESHOLD : float = 0.25

var max_speed : int
var current_hp : float
var current_damage : float
var acceleration : int
var friction : int

var is_charging : bool = false
var can_launch : bool = false

func _ready() -> void:
	initialize_stats()
	weapon.set_damage(current_damage)
	weapon.can_explode = true

func initialize_stats():
	current_hp = Stats.base_hp
	current_damage = Stats.base_damage
	max_speed = Stats.base_speed
	acceleration = Stats.acceleration
	friction = Stats.friction

func get_input() -> Vector2:
	var direction = Input.get_vector("left", "right", "up", "down")
	return direction

func rotate_weapon():
	if weapon.is_busy or !weapon.is_ready:
		return	
	var mouse : Vector2 = get_global_mouse_position()
	var dir_to_mouse : Vector2 = weapon_pivot.global_position.direction_to(mouse)
	var angle : float = dir_to_mouse.angle()

	if mouse.x < global_position.x:
		pivot.scale.x = -1
	else:
		pivot.scale.x = 1

	weapon_pivot.global_rotation = lerp_angle(weapon_pivot.global_rotation, angle, 0.175)

func charge_weapon_start():
	weapon_charge_timer.start(CHARGE_THRESHOLD)
	weapon.charge()
	is_charging = true
	
func charge_weapon_stop():
	weapon_charge_timer.stop()
	if is_instance_valid(weapon):
		weapon.stop_charge()
	is_charging = false
	can_launch = false
	
func attack():
	if !is_instance_valid(weapon):
		return
	var success : bool = weapon.attack("Swing")

func take_damage(_weapon : Node2D, _knockback : bool = false):
	print("Ouch")
	if fsm.current_state.name == "HitState":
		return
		
	fsm.transition("HitState")	
	if _knockback:
		knockback(_weapon)
	
func knockback(hit_by : Weapon):
	var direction : Vector2
	var force = min(hit_by.current_damage * 50, 200)
	if hit_by.is_launched:
		direction = global_position.direction_to(hit_by.global_position) * -1
	else:
		direction = global_position.direction_to(hit_by.user.global_position) * -1
	velocity = direction * force
	fsm.transition("HitState")	

func throw_weapon():
	if !weapon.is_ready:
		return
	if can_launch:
		weapon.launch()
		is_charging = false
		can_launch = false
	else:
		charge_weapon_stop()


func _on_weapon_charge_timer_timeout() -> void:
	can_launch = true
