extends Node
class_name Utils

static var amount_thresholds : Dictionary = {
	0 : 0.66,
	1 : 0.2,
	2 : 0.1,
	3 : 0.04
}

static func get_amount() -> int:
	var roll = randf()
	var amount : int = 0
	var total_chance : float = 0
	for key in amount_thresholds.keys():	
		total_chance += amount_thresholds[key]
		if roll < total_chance:
			amount = key
			return key
	return amount

static func generate_poisson_points(radius : float, _region_size : Vector2):
	var cell_size : float = radius / sqrt(2.0)
	var region_size : Vector2 = _region_size

	var grid = []
	grid.resize(ceil(region_size.x / cell_size))
	if grid.size() == 0:
		return PackedVector2Array([])
	for i in grid.size():
		grid[i] = []
		grid[i].resize(ceil(region_size.y / cell_size))
		for j in grid[i].size():
			grid[i][j] = 0
	
	var points : PackedVector2Array = []
	var spawn_points : PackedVector2Array = []
	spawn_points.append(region_size * 0.5)

	while spawn_points.size() > 0:
		var index : int = randi() % spawn_points.size()
		var spawn_center : Vector2 = spawn_points[index]
		var accepted : bool = false

		for _i in range(20):
			var angle : float = randf_range(0, TAU)
			var dir : Vector2 = Vector2.RIGHT.rotated(angle)
			var candidate : Vector2 = spawn_center + dir * randf_range(radius, radius * 2)
			
			if is_valid(candidate, region_size, cell_size, radius, points, grid):
				points.append(candidate)
				spawn_points.append(candidate)
				grid[int(candidate.x / cell_size)][int(candidate.y / cell_size)] = points.size()
				accepted = true
				break
		if !accepted:
			spawn_points.remove_at(index)
	
	return points
	
static func is_valid(candidate : Vector2, region_size : Vector2, cell_size : float, radius : float, points : PackedVector2Array, grid : Array):
	if candidate.x >= 0 and candidate.x < region_size.x and candidate.y >=0 and candidate.y < region_size.y:
		var cell_x : int = candidate.x / cell_size
		var cell_y : int = candidate.y / cell_size
		
		var search_start_x = max(0, cell_x - 2)
		var search_start_y = max(0, cell_y - 2)
		var search_end_x = min(cell_x + 2, grid.size() - 1)
		var search_end_y = min(cell_y + 2, grid[0].size() - 1)
		
		for x in range(search_start_x, search_end_x + 1):
			for y in range(search_start_y, search_end_y + 1):
				var point_index = grid[x][y] - 1
				if point_index != -1:
					var distance : float = candidate.distance_squared_to(points[point_index])
					if distance < radius * radius:
						return false
		return true
	return false
