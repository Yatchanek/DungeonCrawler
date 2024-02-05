extends Node2D
class_name Weapon

var explosion_scene = preload("res://scenes/explosion.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var weapon: Sprite2D = $Weapon
@onready var hurtbox: HurtBox = $Weapon/Hurtbox


@export var weapon_pivot : Marker2D
@export var user : CharacterBody2D

const MAX_SPEED : int = 900
const ACCELERATION : float = 3000.0

var is_busy : bool = false
var is_charging : bool = false
var is_launched : bool = false
var is_ready : bool = true
var can_explode : bool = false

var lifetime : float = 1.0
var velocity : Vector2

var base_damage : float
var current_damage : float

var speed : float = 0

signal destroyed

func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	velocity = Vector2.ZERO
	if user:
		hurtbox.attacker = user

func set_damage(_damage):
	base_damage = _damage
	current_damage = base_damage	

	
func _process(delta: float) -> void:
	animation_player.speed_scale = clamp(animation_player.speed_scale + delta, 0.5, 1.5)
	current_damage = clamp(current_damage * (1 + delta), base_damage, base_damage * 3)

func _physics_process(delta: float) -> void:
	speed = clamp(speed + ACCELERATION * delta, 0, MAX_SPEED)
	velocity = transform.x * speed
	
	global_position += velocity * delta

	lifetime -= delta
	if lifetime <= 0:
		return_to_hand()

func abort():
	animation_player.call_deferred("stop")
	is_busy = false
	hurtbox.deactivate()
		
func attack(anim_name : String):
	if is_busy or is_charging or !is_ready:
		return false
	animation_player.play(anim_name)
	is_busy = true
	return true

func charge():
	is_charging = true
	animation_player.speed_scale = 0.5
	animation_player.play("Charge")
	set_process(true)
	
func stop_charge():
	is_charging = false
	set_process(false)
	animation_player.speed_scale = 1.0
	weapon.position = Vector2(30, 0)
	animation_player.stop()
	
func launch():
	set_as_top_level(true)
	global_position = weapon_pivot.global_position + Vector2(15, 0).rotated(weapon_pivot.global_rotation)
	global_rotation = weapon_pivot.global_rotation
	animation_player.stop()
	set_physics_process(true)
	lifetime = 1.0
	is_launched = true
	is_charging = false
	hurtbox.activate()

func return_to_hand():
	set_physics_process(false)
	set_as_top_level(false)
	is_launched = false
	is_ready = false
	modulate.a = 0.0
	hurtbox.deactivate()
	global_position = weapon_pivot.global_position + Vector2(15, 0).rotated(weapon_pivot.global_rotation)
	global_rotation = weapon_pivot.global_rotation
	appear()

func appear():
	var tw : Tween = create_tween()
	tw.finished.connect(_on_tween_finished)
	tw.tween_interval(0.5)
	tw.tween_property(self, "modulate:a", 1.0, 0.15)

func explode():
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = CircleShape2D.new() as CircleShape2D
	query.shape.radius = 72
	query.transform.origin = hurtbox.global_transform.origin
	query.collision_mask = hurtbox.collision_mask - 16
	var state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var result = state.intersect_shape(query)
	if result:
		for hit in result:
			hit.collider.take_damage(self, true)
		
	var explosion = explosion_scene.instantiate()
	explosion.global_position = hurtbox.global_position
	call_deferred("add_child", explosion)
	
	return_to_hand()

func _on_animation_player_animation_finished(_anim_name: String) -> void:
	is_busy = false

func _on_tween_finished():
	is_ready = true


func _on_hurtbox_body_entered(_body) -> void:
	if is_launched:
		explode()


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area is HitBox:
		if !is_launched:
			area.target.take_damage(self, true)
		elif can_explode:
			explode()
		else:
			area.target.take_damage(self, true)
			return_to_hand()
