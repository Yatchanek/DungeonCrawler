extends Node2D

var spike_trap_scene = preload("res://scenes/spike_trap.tscn")

@onready var tile_map: TileMap = $TileMap
@onready var detector: Area2D = $Detector


var neighbours : Dictionary = {}


var coords : Vector2i

var layout : int 

const max_room_size_x : int = 24
const min_room_size_x : int = 10
const max_room_size_y : int = 24
const min_room_size_y : int = 10

const min_corridor_length : int = 3

var room_min_x : int
var room_max_x : int
var room_min_y : int
var room_max_y : int
var room_size_x : int
var room_size_y : int

var door_north_start : int
var door_east_start : int
var door_south_start : int
var door_west_start : int

var bump_size_s : int 

var occupied_tiles : Array[Vector2i]
var safe_tiles : Array[Vector2i]

const door_width : int = 4
const door_height : int = 4

const N : int = 1
const E : int = 2
const S : int = 4
const W : int = 8

const tile_size = 32

const cracked_tiles : Array = [Vector2i(2, 4), Vector2i(3, 4), Vector2i(1, 5), Vector2i(2, 5), Vector2i(3, 5)]

var middle_point : Vector2

var visited = false

var total_room_width : int
var total_room_height : int

var dirs : Array = [N, E, S, W]

var decorations : int = 0
# 1 - fountain
# 2 - bump S
# 4 - bump N
# 8 - Goo

var poisson_points : PackedVector2Array = []

signal new_room_reached

#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#if event.pressed:
			#get_tree().reload_current_scene()

#func _draw() -> void:
	#for point in poisson_points:
		#draw_circle(point + Vector2(room_min_x + 2, room_min_y + 3) * 32, 10, Color.WHITE)

func _ready() -> void:
	occupied_tiles = []
	bump_size_s = 0
	total_room_width = max_room_size_x + 2 * min_corridor_length
	total_room_height = max_room_size_y + 2 * min_corridor_length
	define_dimensions()
	position = Vector2(coords.x * total_room_width * tile_map.tile_set.tile_size.x, coords.y * total_room_height * tile_map.tile_set.tile_size.y)
	create_floor()
	create_walls()
	create_doors()
	create_decorations()

	for i in randi_range(0, 3):
		create_traps()
		
	create_columns(randi_range(0, 10))
	for dir in dirs:
		if layout & dir:
			add_detector_shapes(dir)
	if coords == Vector2i.ZERO:
		visited = true
	middle_point = Vector2((room_min_x + room_size_x * 0.5) * tile_size, (room_min_y + room_size_y * 0.5) * tile_size)

	
func create_floor():
	for x in range(room_min_x, room_max_x):
		for y in range(room_min_y + 1, room_max_y):
			tile_map.set_cell(0, Vector2i(x, y), 0, pick_random_floor_tile())
			if x >= room_min_x + 3 and x <= room_max_x - 3 and y >= room_min_y + 3 and y <= room_max_y - 3:
				safe_tiles.append(Vector2i(x, y))

func create_walls():
	for x in range(room_min_x, room_max_x):
		tile_map.set_cell(1, Vector2i(x, room_min_y - 1), 0, Vector2i(1, 0))
		tile_map.set_cell(1, Vector2i(x, room_min_y), 0, Vector2i(2, 1))
		tile_map.set_cell(1, Vector2i(x, room_max_y - 1), 0, Vector2i(1, 0))
		tile_map.set_cell(1, Vector2i(x, room_max_y), 0, Vector2i(2, 1))

	for y in range(room_min_y + 1, room_max_y - 1):
		tile_map.set_cell(1, Vector2i(room_min_x, y), 0, Vector2i(2, 9))
		tile_map.set_cell(1, Vector2i(room_max_x - 1, y), 0, Vector2i(3, 9))

	tile_map.set_cell(1, Vector2i(room_min_x, room_min_y), 0, Vector2i(2, 8))
	tile_map.set_cell(1, Vector2i(room_max_x - 1, room_min_y), 0, Vector2i(3, 8))
	tile_map.set_cell(1, Vector2i(room_max_x - 1, room_min_y - 1), 0, Vector2i(3, 7))
	tile_map.set_cell(1, Vector2i(room_min_x, room_max_y - 1), 0, Vector2i(2, 10))
	tile_map.set_cell(1, Vector2i(room_max_x - 1, room_max_y - 1), 0, Vector2i(3, 10))
	tile_map.set_cell(1, Vector2i(room_min_x, room_max_y), 0, Vector2i(1, 1))
	tile_map.set_cell(1, Vector2i(room_max_x - 1, room_max_y), 0, Vector2i(3, 1))

func create_doors():
	if layout & N != 0:
		for x in range(door_north_start, door_north_start + door_width):
			tile_map.set_cell(1, Vector2i(x, room_min_y - 1))
			tile_map.set_cell(1, Vector2i(x, room_min_y))
		tile_map.set_cell(1, Vector2(door_north_start, room_min_y -1), 0, Vector2i(1, 7))
		tile_map.set_cell(1, Vector2(door_north_start - 1, room_min_y -1), 0, Vector2i(3, 10))
		tile_map.set_cell(1, Vector2(door_north_start, room_min_y), 0, Vector2i(1, 9))
		tile_map.set_cell(1, Vector2(door_north_start + door_width - 1, room_min_y -1), 0, Vector2i(0, 7))
		tile_map.set_cell(1, Vector2(door_north_start + door_width, room_min_y -1), 0, Vector2i(2, 10))
		tile_map.set_cell(1, Vector2(door_north_start + door_width - 1, room_min_y), 0, Vector2i(0, 9))

		for y in range(room_min_y - 2, -1, -1):
			#tile_map.set_cell(1, Vector2(door_north_start, y), 0, Vector2i(2, 9))
			tile_map.set_cell(1, Vector2(door_north_start - 1, y), 0, Vector2i(3, 9))			
			#tile_map.set_cell(1, Vector2(door_north_start + door_width - 1, y), 0, Vector2i(3, 9))
			tile_map.set_cell(1, Vector2(door_north_start + door_width, y), 0, Vector2i(2, 9))	

		for x in range(door_north_start, door_north_start + door_width):
			for y in range(room_min_y, -1, -1):
				tile_map.set_cell(0, Vector2i(x, y), 0, pick_random_floor_tile())


	if layout & S != 0:		
		for x in range(door_south_start, door_south_start + door_width):
			tile_map.set_cell(1, Vector2i(x, room_max_y - 1))
			tile_map.set_cell(1, Vector2i(x, room_max_y))
		#tile_map.set_cell(1, Vector2(door_south_start, room_max_y -1), 0, Vector2i(1, 7))
		tile_map.set_cell(1, Vector2(door_south_start - 1, room_max_y -1), 0, Vector2i(3, 7))
		#tile_map.set_cell(1, Vector2(door_south_start, room_max_y), 0, Vector2i(2, 9))
		tile_map.set_cell(1, Vector2(door_south_start - 1, room_max_y), 0, Vector2i(3, 8))
		tile_map.set_cell(1, Vector2(door_south_start + door_width, room_max_y -1), 0, Vector2i(2, 7))
		tile_map.set_cell(1, Vector2(door_south_start + door_width, room_max_y), 0, Vector2i(2, 8))

#
		for y in range(room_max_y + 1, total_room_height):
			tile_map.set_cell(1, Vector2(door_south_start - 1, y), 0, Vector2i(3, 9))			
			tile_map.set_cell(1, Vector2(door_south_start + door_width, y), 0, Vector2i(2, 9))	
#
		for x in range(door_south_start, door_south_start + door_width):
			for y in range(room_max_y, total_room_height):
				tile_map.set_cell(0, Vector2i(x, y), 0, pick_random_floor_tile())
	

	if layout & E != 0:
		for y in range(door_east_start, door_east_start + door_height):
			tile_map.set_cell(1, Vector2i(room_max_x - 1, y))

		tile_map.set_cell(1, Vector2i(room_max_x - 1, door_east_start), 0, Vector2i(0, 9))
		tile_map.set_cell(1, Vector2i(room_max_x - 1, door_east_start + door_height -1 ), 0, Vector2i(0, 7))
		tile_map.set_cell(1, Vector2i(room_max_x - 1, door_east_start + door_height), 0, Vector2i(0, 8))

		for x in range(room_max_x, total_room_width):
			tile_map.set_cell(1, Vector2i(x, door_east_start - 1), 0, Vector2i(2, 0))
			tile_map.set_cell(1, Vector2i(x, door_east_start), 0, Vector2i(2, 1))
			tile_map.set_cell(1, Vector2i(x, door_east_start + door_height -1 ), 0, Vector2i(2, 0))
			tile_map.set_cell(1, Vector2i(x, door_east_start + door_height), 0, Vector2i(2, 1))
			for y in range(door_east_start + 1, door_east_start + door_height):
				tile_map.set_cell(0, Vector2i(x, y), 0, pick_random_floor_tile())
		
	if layout & W != 0:
		for y in range(door_west_start, door_west_start + door_height):
			tile_map.set_cell(1, Vector2i(room_min_x, y))

		tile_map.set_cell(1, Vector2i(room_min_x, door_west_start), 0, Vector2i(1, 9))
		tile_map.set_cell(1, Vector2i(room_min_x, door_west_start + door_height -1 ), 0, Vector2i(1, 7))
		tile_map.set_cell(1, Vector2i(room_min_x, door_west_start + door_height), 0, Vector2i(1, 8))
		
		for x in range(room_min_x - 1, -1, -1):
			tile_map.set_cell(1, Vector2i(x, door_west_start - 1), 0, Vector2i(2, 0))
			tile_map.set_cell(1, Vector2i(x, door_west_start), 0, Vector2i(2, 1))
			tile_map.set_cell(1, Vector2i(x, door_west_start + door_height -1 ), 0, Vector2i(2, 0))
			tile_map.set_cell(1, Vector2i(x, door_west_start + door_height), 0, Vector2i(2, 1))
			for y in range(door_west_start + 1, door_west_start + door_height):
				tile_map.set_cell(0, Vector2i(x, y), 0, pick_random_floor_tile())

func create_decorations():
	place_statue(Utils.get_amount())
	place_goo(Utils.get_amount())
	
	if layout & N and randf() < 0.25:
		place_door(door_north_start, room_min_y)
		
	if layout & S and randf() < 0.25:
		place_door(door_south_start, room_max_y)
		
	if !layout & S and room_size_x > 14:
		create_bump(S)
		

func place_goo(amount : int):
	for i in amount:
		var pos_x : int
		var max_attempts : int = 10
		var attempts : int = 1
		pos_x = get_pos_x()
		while occupied_tiles.has(Vector2i(pos_x, room_min_y)) or !pos_x:
			attempts += 1
			if attempts >= max_attempts:
				break
			pos_x = get_pos_x()	

		if pos_x:
			if randf() < 0.5:
				tile_map.set_cell(1, Vector2i(pos_x, room_min_y), 0, Vector2i(4,5))
				tile_map.set_cell(0, Vector2i(pos_x, room_min_y + 1), 0, Vector2i(4,6))
			else:	
				tile_map.set_cell(1, Vector2i(pos_x, room_min_y), 0, Vector2i(3,3))
			
			decorations += 8
			occupied_tiles.append(Vector2i(pos_x, room_min_y))

func place_statue(amount : int):
	for i in amount:
		var pos_x : int
		var max_attempts : int = 10
		var attempts : int = 1
		pos_x = get_pos_x()
		while !pos_x or occupied_tiles.has(Vector2i(pos_x, room_min_y)):
			attempts += 1
			if attempts >= max_attempts:
				break
			pos_x = get_pos_x()	
		
		if pos_x:
			if randf() < 0.5:	
				tile_map.set_cell(1, Vector2i(pos_x, room_min_y), 0, Vector2i(4,3))
				tile_map.set_cell(1, Vector2i(pos_x, room_min_y + 1), 0, Vector2i(4,4))
			else:
				tile_map.set_cell(1, Vector2i(pos_x, room_min_y - 1), 0, Vector2i(6,0))
				tile_map.set_cell(1, Vector2i(pos_x, room_min_y), 0, Vector2i(6,1))
				tile_map.set_cell(1, Vector2i(pos_x, room_min_y + 1), 0, Vector2i(6,2))
			decorations += 1
		occupied_tiles.append(Vector2i(pos_x, room_min_y))
		

func get_pos_x():
	var pos_x : int
	if layout & N:
		var left_ok = door_north_start - room_min_x > 6
		var right_ok = room_max_x - door_north_start - 4 > 6
		if !left_ok and !right_ok:
			return pos_x
		if left_ok and right_ok:
			pos_x = randi_range(room_min_x + 3, door_north_start - 3) if randf() < 0.5 else randi_range(door_north_start + door_width + 3, room_max_x - 3)
		elif left_ok and !right_ok:
			pos_x = randi_range(room_min_x + 3, door_north_start - 3)
		elif right_ok and !left_ok:
			pos_x = randi_range(door_north_start + door_width + 2, room_max_x - 2)
		
	else:
		pos_x = randi_range(room_min_x + 3, room_max_x - 3)
		
	return pos_x	
	
func create_traps(attempts : int = 1):
	var spike_trap = spike_trap_scene.instantiate()
	var pos : Vector2i
	
	pos = get_safe_tile()	

	spike_trap.position = tile_map.map_to_local(pos)
	occupied_tiles.append(pos)
	call_deferred("add_child", spike_trap)

func create_columns(amount):
	var points : PackedVector2Array = Utils.generate_poisson_points(96, Vector2(room_size_x - 4, room_size_y - bump_size_s - 6) * 32)
	if points.size() == 0:
		return
	while amount > 0:
		var idx = randi() % points.size()
		var pos = tile_map.local_to_map(points[idx] + Vector2(room_min_x + 2, room_min_y + 3) * 32)

		if occupied_tiles.has(pos) or occupied_tiles.has(pos + Vector2i(0, -1)) or occupied_tiles.has(pos + Vector2i(0, -2)):
			points.remove_at(idx)
			if points.is_empty():
				break
			else:
				continue	

		tile_map.set_cell(1, pos, 0, Vector2i(5, 7))
		tile_map.set_cell(1, pos + Vector2i(0, -1), 0, Vector2i(5, 6))
		tile_map.set_cell(1, pos + Vector2i(0, -2), 0, Vector2i(5, 5))
			
		occupied_tiles.append(pos)
		occupied_tiles.append(pos + Vector2i(0, -1))
		occupied_tiles.append(pos + Vector2i(0, -2))
		safe_tiles.erase(pos)
		safe_tiles.erase(pos + Vector2i(0, -1))
		safe_tiles.erase(pos + Vector2i(0, -2))
		amount -= 1

	
func create_bump(dir : int):
	if dir == S and randf() < 0.33:
		var bump_start = room_min_x + randi_range(3, min(floor(room_size_x * 0.5), 8))
		var bump_end = room_max_x - + randi_range(3, min(floor(room_size_x * 0.5), 8))
		bump_size_s = randi_range(4, 6)
		
		for i in range(bump_start, bump_end):
			tile_map.set_cell(1, Vector2i(i, room_max_y))
			tile_map.set_cell(1, Vector2i(i, room_max_y - 1))
			tile_map.set_cell(1, Vector2i(i, room_max_y - bump_size_s), 0, Vector2i(2, 0))
			tile_map.set_cell(1, Vector2i(i, room_max_y - bump_size_s + 1), 0, Vector2i(2, 1))
			safe_tiles.erase(Vector2i(i,  room_max_y - bump_size_s - 1))
			for j in range(room_max_y, room_max_y - bump_size_s, -1):
				tile_map.set_cell(0, Vector2i(i, j))
				safe_tiles.erase(Vector2i(i, j))
			
		tile_map.set_cell(1, Vector2i(bump_start, room_max_y), 0, Vector2i(1, 9))
		tile_map.set_cell(1, Vector2i(bump_end - 1, room_max_y), 0, Vector2i(0, 9))
		tile_map.set_cell(1, Vector2i(bump_start, room_max_y - bump_size_s), 0, Vector2i(2, 7))
		tile_map.set_cell(1, Vector2i(bump_start, room_max_y - bump_size_s + 1), 0, Vector2i(2, 8))
		tile_map.set_cell(1, Vector2i(bump_end -1 , room_max_y - bump_size_s), 0, Vector2i(3, 7))
		tile_map.set_cell(1, Vector2i(bump_end - 1, room_max_y - bump_size_s + 1), 0, Vector2i(3, 8))		
		
		for j in range(room_max_y - 1, room_max_y - bump_size_s + 1, -1):
			tile_map.set_cell(1, Vector2i(bump_start, j), 0, Vector2i(2, 9))		
			tile_map.set_cell(1, Vector2i(bump_end - 1, j), 0, Vector2i(3, 9))
		decorations += 2

func define_dimensions():
	var border_x_nw : int
	var border_x_ne : int
	var border_x_sw : int
	var border_x_se : int
	var border_y_ne : int
	var border_y_se : int
	var border_y_nw : int
	var border_y_sw : int
	
	if layout & N:
		if neighbours.has(Vector2i(0, -1)):
			door_north_start = neighbours[Vector2i(0, -1)].door_south_start
		else:
			door_north_start = randi_range(min_corridor_length + 3, total_room_width - min_corridor_length - 7)
		
	if layout & S:
		if neighbours.has(Vector2i(0, 1)):
			door_south_start = neighbours[Vector2i(0, 1)].door_north_start
		else:
			door_south_start = randi_range(min_corridor_length + 3, total_room_width - min_corridor_length - 7)

	if layout & E:
		if neighbours.has(Vector2i(1, 0)):
			door_east_start = neighbours[Vector2i(1, 0)].door_west_start
		else:
			door_east_start = randi_range(min_corridor_length + 3, total_room_height - min_corridor_length - 7)
		

	if layout & W:
		if neighbours.has(Vector2i(-1, 0)):
			door_west_start = neighbours[Vector2i(-1, 0)].door_east_start
		else:
			door_west_start = randi_range(min_corridor_length + 3, total_room_height - min_corridor_length - 7)

	border_x_nw = door_north_start - 3	if door_north_start else 1000
	border_x_ne = door_north_start + 7	if door_north_start else -1000
	border_x_sw = door_south_start - 3  if door_south_start else 1000
	border_x_se = door_south_start + 7  if door_south_start else -1000
	border_y_ne = door_east_start - 3 if door_east_start else 1000
	border_y_se = door_east_start + 7 if door_east_start else -1000
	border_y_nw = door_west_start - 3 if door_west_start else 1000
	border_y_sw = door_west_start + 7 if door_west_start else -1000
							
	if !door_north_start and !door_south_start:
		room_min_x = randi_range(min_corridor_length, total_room_width - min_corridor_length - min_room_size_x)
		room_max_x = room_min_x + randi_range(min_room_size_x, max_room_size_x - room_min_x)
	
	else:
		room_min_x = randi_range(min_corridor_length, min(border_x_nw, border_x_sw))	
		room_max_x = randi_range(max(border_x_ne, border_x_se), min_corridor_length + max_room_size_x)

		
	if !door_east_start and !door_west_start:		
		room_min_y = randi_range(min_corridor_length, total_room_height - min_corridor_length - min_room_size_y)
		room_max_y = room_min_y + randi_range(min_room_size_y, max_room_size_y - room_min_y)
	else:
		room_min_y = randi_range(min_corridor_length, min(border_y_ne, border_y_nw))
		room_max_y = randi_range(max(border_y_se, border_y_sw), min_corridor_length + max_room_size_y)
	
	room_size_x = room_max_x - room_min_x
	room_size_y = room_max_y - room_min_y

	
func add_detector_shapes(side : int):
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = RectangleShape2D.new()
	if side == N:
		collision_shape.shape.size = Vector2(door_width * tile_size, tile_size)
		collision_shape.position = Vector2((door_north_start + door_width * 0.5) * tile_size, -0.5 * tile_size)
	
	elif side == S:
		collision_shape.shape.size = Vector2(door_width * tile_size, tile_size)
		collision_shape.position = Vector2((door_south_start + door_width * 0.5) * tile_size, (total_room_height -0.5) * tile_size)
	
	elif side == E:
		collision_shape.shape.size = Vector2(tile_size, (door_width - 1) * tile_size)
		collision_shape.position = Vector2((total_room_width - 0.5)* tile_size, (door_east_start + door_width * 0.5 + 0.5) * tile_size)

	else:
		collision_shape.shape.size = Vector2(tile_size, (door_width - 1) * tile_size)
		collision_shape.position = Vector2(0.5 * tile_size, (door_west_start + door_width * 0.5 + 0.5) * tile_size)
	
	
	detector.call_deferred("add_child", collision_shape)

func pick_random_floor_tile() -> Vector2i:
	if randf() < 0.9:
		return Vector2i(1, 4)
	
	return cracked_tiles.pick_random()

func place_door(x, y):
	tile_map.set_cell(1, Vector2i(x, y), 0, Vector2i(1, 16))
	tile_map.set_cell(1, Vector2i(x, y - 1), 0, Vector2i(1, 15))
	tile_map.set_cell(1, Vector2i(x + 1, y), 0, Vector2i(5, 16))
	tile_map.set_cell(1, Vector2i(x + 1, y - 1), 0, Vector2i(5, 15))
	tile_map.set_cell(1, Vector2i(x + 2, y), 0, Vector2i(6, 16))
	tile_map.set_cell(1, Vector2i(x + 2, y - 1), 0, Vector2i(6, 15))
	tile_map.set_cell(1, Vector2i(x + 3, y), 0, Vector2i(4, 16))
	tile_map.set_cell(1, Vector2i(x + 3, y - 1), 0, Vector2i(4, 15))
	tile_map.set_cell(1, Vector2i(x + 1, y - 2), 0, Vector2i(2, 14))
	tile_map.set_cell(1, Vector2i(x + 2, y - 2), 0, Vector2i(3, 14))

func get_safe_tile(pop_tile : bool = true) -> Vector2i:
	if pop_tile:
		return safe_tiles.pop_at(randi() % safe_tiles.size())
	else:
		return safe_tiles.pick_random()

func activate():
	for i in randf_range(0, 3):
		var pos = tile_map.map_to_local(get_safe_tile())
		EnemyManager.spawn_enemy(coords, pos)

func _on_detector_body_entered(_body) -> void:
	new_room_reached.emit(coords, !visited)
	if !visited:
		visited = true
		activate()
