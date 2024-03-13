extends Node2D

var room_scene = preload("res://scenes/room.tscn")



var grid = {}
var room_dict = {}

const N = 1 #0001
const E = 2 #0010
const S = 4 #0100
const W = 8 #1000

const doors = {
	Vector2i(0, -1) : N,
	Vector2i(1, 0)  : E,
	Vector2i(0, 1)  : S,
	Vector2i(-1, 0) : W,
}

const dirs = [
	Vector2i(0, 0), Vector2i(0, -1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1),
	Vector2i(0, 1), Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(-1, -1)			
]



const weights : Dictionary = {
	1 : 0.5,
	2 : 0.5,
	3 : 1.2,
	4 : 0.5,
	5 : 1.5,
	6 : 1.0,
	7 : 1.75,
	8 : 0.5,
	9 : 1.0,
	10 : 1.0,
	11 : 1.75,
	12 : 1.0,
	13 : 1.75,
	14 : 1.75,
	15 : 5.5,
}

const total_room_width : int = 30
const total_room_height : int = 30

var rooms_visited : int = 0

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

func _ready() -> void:
	for dir in dirs:
		add_room(Vector2i.ZERO + dir)
	var starting_room = room_dict[Vector2i.ZERO]
	await  get_tree().process_frame
	$Player.global_position = to_global(starting_room.middle_point)
	EnemyManager.enemy_spawned.connect(_on_enemy_spawned)


func add_room(coords):
	if grid.has(coords):
		return
	var num : int
	var rooms: PackedInt32Array = get_valid_rooms(coords)
	if rooms.size() == 0:
		return
	num = get_random(rooms)	
	place_room(coords, num)

func place_room(coords, num):
	grid[coords] = num
	var room := room_scene.instantiate()
	room.new_room_reached.connect(_on_spawn_area_reached)
	room.layout = num
	room.coords = coords
	room_dict[coords] = room
	for door in doors.keys():
		if room_dict.has(coords + door):
			room.neighbours[door] = room_dict[coords + door]
	call_deferred("add_child", room)
	
func get_valid_rooms(coords) -> PackedInt32Array:
	var rooms : PackedInt32Array = []
	var no_neighbours : bool = true
	for i in range(1, 16):
		var is_match : bool = false
		for dir in doors.keys():
			if grid.has(coords + dir):
				no_neighbours = false
				if (grid[coords + dir] & doors[-dir]) / doors[-dir] == (i & doors[dir]) / doors[dir]:
					is_match = true
				else:
					is_match = false
					break
		if is_match:
			rooms.push_back(i)
	if no_neighbours:
		rooms.push_back(15)
	return rooms

func get_random(arr : PackedInt32Array) -> int:
	if arr.size() == 1:
		return arr[0]
	
	var total_weights : float = 0.0
	for element in arr:
		total_weights += weights[element]
	
	var total_chance : float = 0.0
	for i in arr.size():
		total_chance += weights[arr[i]]
		if randf() * total_weights < total_chance:
			return arr[i]
	
	return arr[arr.size() - 1]

func destroy_distant_rooms(current_coords):
	var state = get_world_2d().direct_space_state
	for coords in grid.keys():
		if abs(coords.x - current_coords.x) > 1 or abs(coords.y - current_coords.y) > 1:
			grid.erase(coords)
			var query = PhysicsShapeQueryParameters2D.new()
			query.collision_mask = 4
			query.shape = RectangleShape2D.new()
			query.shape.size = Vector2(30, 30) * 32
			query.transform.origin = Vector2(coords) * 30 * 32 + Vector2(15, 15) * 32
			var result = state.intersect_shape(query)
			if result:
				for hit in result:
					hit.collider.queue_free()
			room_dict[coords].queue_free()
			room_dict.erase(coords)

func _on_spawn_area_reached(coords, is_new_room):
	if is_new_room:
		rooms_visited += 1
	for dir in dirs:
		if !grid.has(coords + dir):
			add_room(coords + dir)
	destroy_distant_rooms(coords)

func _on_enemy_spawned(enemy : CharacterBody2D, coords : Vector2i):
	enemy.position += room_dict[coords].position
	call_deferred("add_child", enemy)


