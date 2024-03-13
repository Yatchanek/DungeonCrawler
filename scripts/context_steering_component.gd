extends Node2D
class_name ContextSteeringComponent

@export var num_rays : int = 8
@export var sight_range : int = 72
@export var actor : CharacterBody2D
@export_category("Collision Mask") 
@export var layers : Dictionary = {
	1: false,
	2: false,
	3: false,
	4: false,
	5: false,
	6: false,
	7: false,
	8: false,
	9: false,
	10: false,
}

var interest : Array = []
var danger : Array = []
var ray_directions : Array = []
var collision_mask : int


#func _draw():
	#for i in num_rays:
		#draw_line(Vector2.ZERO, ray_directions[i] * interest[i] * sight_range, Color.WHITE, 2.0)
		#draw_line(Vector2.ZERO, ray_directions[i] * danger[i] * sight_range, Color.RED, 2.0)

func _ready() -> void:
	for key in layers.keys():
		if layers[key]:
			collision_mask += pow(2, key - 1)
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
		danger[i] = 0
	
	var state = EnemyManager.world_state
	var rid : RID = actor.get_rid()
	for i in num_rays:
		var query = PhysicsRayQueryParameters2D.create(actor.global_position, actor.global_position + ray_directions[i] * sight_range, collision_mask, [rid])
		var result = state.intersect_ray(query)
		
		if result:
			var c_p = result.position
			danger[i] = 1 - actor.global_position.distance_to(c_p) / sight_range
			
	for i in num_rays:
		if danger[i] > 0:
			var opposite_idx = wrapi(i + num_rays * 0.5, 0, num_rays)
			interest[opposite_idx] += danger[i]
			interest[i] -= danger[i]


	var chosen_direction = Vector2.ZERO

	for i in num_rays:
		chosen_direction += ray_directions[i] * interest[i]
	
	chosen_direction = chosen_direction.normalized()	

	return chosen_direction
