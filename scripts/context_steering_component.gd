extends Node
class_name ContextSteeringComponent

@export var num_rays : int = 8
@export var sight_range : int = 72
@export var actor : CharacterBody2D
@export var collision_mask : int = 3

var interest : Array = []
var danger : Array = []
var ray_directions : Array = []

func _ready() -> void:
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	for i in num_rays:
		var angle = i * (TAU / num_rays)
		ray_directions[i] = Vector2.RIGHT.rotated(angle)
		interest[i] = 0
		danger[i] = 0
		
func get_context_steering(dir : Vector2) -> Vector2:
	for i in num_rays:
		var d = ray_directions[i].dot(dir)
		interest[i] = max(0, d)
	
	var state = EnemyManager.world_state
	var rid : RID = actor.get_rid()
	for i in num_rays:
		var query = PhysicsRayQueryParameters2D.create(actor.global_position, actor.global_position + ray_directions[i] * sight_range, collision_mask, [rid])
		var result = state.intersect_ray(query)
		
		if result:
			interest[i] = 0

		
	var chosen_direction = Vector2.ZERO

	for i in num_rays:
		chosen_direction += ray_directions[i] * interest[i]
	
	chosen_direction = chosen_direction.normalized()	

	return chosen_direction
