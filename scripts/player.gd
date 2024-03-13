extends CharacterBody2D
class_name Player

@onready var weapon_pivot: Marker2D = $Pivot/WeaponPivot
@onready var weapon: Weapon = $Pivot/WeaponPivot/MeleeWeapon
@onready var body: Sprite2D = $Pivot/Body
@onready var anim_player : AnimationPlayer  = $AnimationPlayer
@onready var pivot : Marker2D = $Pivot
@onready var charge_delay_timer: Timer = $ChargeDelayTimer
@onready var fsm: FiniteStateMachine = $FSM

@export var Stats : StatsData

const CHARGE_DELAY : float = 0.25
const FULL_CHARGE : float = 15

const CHARGED_ATTACK_COST = 5

var weapon_charge_amount : float = FULL_CHARGE


var max_speed : int
var max_hp : int
var current_hp : float
var current_damage : float
var current_charge_speed : float
var acceleration : int
var friction : int

var is_charging : bool = false
var can_launch : bool = false

signal health_changed
signal charge_amount_changed

func _ready() -> void:
	initialize_stats()
	weapon.initialize_damage(current_damage)
	weapon.can_explode = true
	ready.connect(EnemyManager._on_player_ready.bind(self))
	ready.connect(get_parent().get_parent()._on_player_ready.bind(self))
	health_changed.connect(get_parent().get_parent()._on_player_health_changed)
	charge_amount_changed.connect(get_parent().get_parent()._on_player_charge_amount_changed)
	set_process(false)

func _process(delta: float) -> void:
	weapon_charge_amount += current_charge_speed * delta
	charge_amount_changed.emit(weapon_charge_amount / FULL_CHARGE * 100)
	if weapon_charge_amount >= FULL_CHARGE:
		weapon_charge_amount = FULL_CHARGE
		set_process(false)

func initialize_stats():
	max_hp = Stats.base_hp
	current_hp = Stats.base_hp
	current_damage = Stats.base_damage
	current_charge_speed = Stats.base_charge_speed
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
	if weapon_charge_amount < CHARGED_ATTACK_COST:
		return
	charge_delay_timer.start(CHARGE_DELAY)
	weapon.charge()
	is_charging = true
	
func charge_weapon_stop():
	charge_delay_timer.stop()
	if is_instance_valid(weapon):
		weapon.stop_charge()
	is_charging = false
	can_launch = false
	
func attack():
	if !is_instance_valid(weapon):
		return
	var _success : bool = weapon.attack("Swing")

func take_damage(hit_by : HurtEntity):
	if fsm.current_state.name == "HitState":
		return
	current_hp -= hit_by.current_damage
	health_changed.emit(current_hp)
	if current_hp <= 0:
		get_tree().call_deferred("reload_current_scene")
	else:
		fsm.transition("HitState")	
		if hit_by.has_knockback:
			knockback(hit_by)
	
func knockback(hit_by : Node2D):
	var direction : Vector2
	var force = min(hit_by.current_damage * 100, 250)
	direction = global_position.direction_to(hit_by.global_position) * -1
	velocity = direction * force
	fsm.transition("HitState")	

func throw_weapon():
	if !weapon.is_ready:
		return
	if can_launch:
		weapon_charge_amount -= CHARGED_ATTACK_COST
		charge_amount_changed.emit(weapon_charge_amount / FULL_CHARGE * 100)
		weapon.launch()
		is_charging = false
		can_launch = false
		set_process(true)
	else:
		charge_weapon_stop()


func _on_charge_delay_timer_timeout() -> void:
	can_launch = true
