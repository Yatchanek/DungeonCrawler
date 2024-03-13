extends HurtEntity
class_name Projectile

var velocity : Vector2
var direction : Vector2
var speed : int = 720

var fired_by : Weapon
var lifetime : float = 1.5

var collision_exception : CharacterBody2D

@onready var hurtbox: HurtBox = $Hurtbox
@onready var core: Area2D = $Core

func _ready() -> void:
	velocity = global_transform.x * speed
	hurtbox.attacker = fired_by

func _physics_process(delta: float) -> void:
	position += velocity * delta
	lifetime -= delta
	if lifetime <= 1.45:
		hurtbox.activate()
	if lifetime <= 0:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area != hurtbox:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	#print("Body entered")
	queue_free()
	



func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area is HitBox and area.target != collision_exception:
		queue_free()
	


func _on_hurtbox_body_entered(body: Node2D) -> void:
	queue_free()
