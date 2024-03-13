extends Weapon
class_name MeleeWeapon

var explosion_scene = preload("res://scenes/explosion.tscn")

@onready var explosion_spawn_position: Marker2D = $ExplosionSpawnPosition
@onready var hurtbox: HurtBox = $Hurtbox

var can_explode : bool = false
var speed : float = 0
var lifetime : float = 1.0
var velocity : Vector2


func _ready() -> void:
	super()
	hurtbox.attacker = self
	velocity = Vector2.ZERO

func _process(delta: float) -> void:
	animation_player.speed_scale = clamp(animation_player.speed_scale + delta, 0.5, 1.5)
	current_damage = clamp(current_damage * (1 + delta), base_damage, base_damage * 3)

func _physics_process(delta: float) -> void:
	speed = clamp(speed + ACCELERATION * delta, 0, MAX_SPEED)
	velocity = global_transform.x * speed
	
	global_position += velocity * delta
	lifetime -= delta
	if lifetime <= 0:
		return_to_hand()

func abort():
	animation_player.call_deferred("stop")
	is_busy = false
	hurtbox.deactivate()
		
func charge():
	is_charging = true
	animation_player.speed_scale = 0.5
	animation_player.play("Charge")
	set_process(true)
	
func stop_charge():
	is_charging = false
	set_process(false)
	animation_player.speed_scale = 1.0
	position = Vector2.ZERO
	animation_player.stop()
	
func launch():
	animation_player.stop()
	set_as_top_level(true)
	global_position = weapon_pivot.global_position + Vector2(20, 0).rotated(weapon_pivot.global_rotation)
	global_rotation = weapon_pivot.global_rotation
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
	global_position = weapon_pivot.global_position + Vector2(20, 0).rotated(weapon_pivot.global_rotation)
	global_rotation = weapon_pivot.global_rotation
	animation_player.speed_scale = 1.0
	appear()


func explode():
	if can_explode:
		#var query = PhysicsShapeQueryParameters2D.new()
		#query.shape = CircleShape2D.new() as CircleShape2D
		#query.shape.radius = 72
		#query.transform.origin = hurtbox.global_transform.origin
		#query.collision_mask = explosion_collision_mask
		#var state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
		#var result = state.intersect_shape(query)
		#if result:
			#for hit in result:
				#hit.collider.take_damage(self)
			
		var explosion = explosion_scene.instantiate()
		explosion.global_position = explosion_spawn_position.global_position
		explosion.caused_by = self
		call_deferred("add_child", explosion)
	
	return_to_hand()
	
func _on_hurtbox_body_entered(_body) -> void:
	if is_launched:
		explode()


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area is HitBox and is_launched:
		explode()
