extends Node2D

@onready var tile_map: TileMap = $TileMap

var layout : int
var coords : Vector2i

var room_width : float
var room_height : float

const crack_tiles = [Vector2i(2, 4), Vector2i(2, 5), Vector2i(3, 4)]

signal new_room_reached

func _ready() -> void:
	room_width = 26 * tile_map.tile_set.tile_size.x
	room_height = 17 * tile_map.tile_set.tile_size.y
	initialize()
	if coords == Vector2i.ZERO:
		$Area2D.queue_free()

func initialize():
	layout = 2
	create_doors()
	add_decorations()
	position = Vector2(coords.x * room_width, coords.y * room_height)
	
func create_doors():
	if layout & 1 != 0:
		for i in range(12, 14):
			tile_map.set_cell(1, Vector2i(i, 2))	
			tile_map.set_cell(1, Vector2i(i, 3))
			
		tile_map.set_cell(1, Vector2i(11, 3), 0, Vector2i(1, 9))
		tile_map.set_cell(1, Vector2i(11, 2), 0, Vector2i(1, 8))
		tile_map.set_cell(1, Vector2i(14, 3), 0, Vector2i(0, 9))
		tile_map.set_cell(1, Vector2i(14, 2), 0, Vector2i(0, 8))
		
		for i in range(0, 2):
			tile_map.set_cell(1, Vector2i(11, i), 0, Vector2i(2, 9))
			tile_map.set_cell(1, Vector2i(14, i), 0, Vector2i(3, 9))
	
		for i in range(11, 15):
			for j in range(0, 4):
				tile_map.set_cell(0, Vector2i(i, j), 0, Vector2i(1, 4))
		
	if layout & 2 != 0:
		for i in range(5, 10):
			tile_map.set_cell(1, Vector2i(22, i))

		tile_map.set_cell(1, Vector2i(22, 5), 0, Vector2i(0, 8))
		tile_map.set_cell(1, Vector2i(22, 6), 0, Vector2i(0, 9))
		tile_map.set_cell(1, Vector2i(22, 9), 0, Vector2i(0, 7))
		
		for i in range(23, 26):
			tile_map.set_cell(1, Vector2i(i, 5), 0, Vector2i(1, 0))
			tile_map.set_cell(1, Vector2i(i, 6), 0, Vector2i(1, 1))
			tile_map.set_cell(1, Vector2i(i, 9), 0, Vector2i(1, 0))
			tile_map.set_cell(1, Vector2i(i, 10), 0, Vector2i(1, 1))

		for i in range(23, 26):
			for j in range(7, 10):
				tile_map.set_cell(0, Vector2i(i, j), 0, Vector2i(1, 4))

	if layout & 4 != 0:
		for i in range(12, 14):
			tile_map.set_cell(1, Vector2i(i, 12))	
			tile_map.set_cell(1, Vector2i(i, 13))
			
		tile_map.set_cell(1, Vector2i(11, 12), 0, Vector2i(1, 7))
		tile_map.set_cell(1, Vector2i(11, 13), 0, Vector2i(2, 9))
		tile_map.set_cell(1, Vector2i(14, 12), 0, Vector2i(0, 7))
		tile_map.set_cell(1, Vector2i(14, 13), 0, Vector2i(3, 9))
		
		for i in range(13, 17):
			tile_map.set_cell(1, Vector2i(11, i), 0, Vector2i(2, 9))
			tile_map.set_cell(1, Vector2i(14, i), 0, Vector2i(3, 9))
	
		for i in range(11, 15):
			for j in range(14, 17):
				tile_map.set_cell(0, Vector2i(i, j), 0, Vector2i(1, 4))

	if layout & 8 != 0:
		for i in range(5, 10):
			tile_map.set_cell(1, Vector2i(3, i))

		tile_map.set_cell(1, Vector2i(3, 5), 0, Vector2i(1, 8))
		tile_map.set_cell(1, Vector2i(3, 6), 0, Vector2i(1, 9))
		tile_map.set_cell(1, Vector2i(3, 9), 0, Vector2i(1, 7))
		
		for i in range(0, 3):
			tile_map.set_cell(1, Vector2i(i, 5), 0, Vector2i(1, 0))
			tile_map.set_cell(1, Vector2i(i, 6), 0, Vector2i(1, 1))
			tile_map.set_cell(1, Vector2i(i, 9), 0, Vector2i(1, 0))
			tile_map.set_cell(1, Vector2i(i, 10), 0, Vector2i(1, 1))

		for i in range(0, 3):
			for j in range(7, 10):
				tile_map.set_cell(0, Vector2i(i, j), 0, Vector2i(1, 4))

func add_decorations():
	add_cracks()
	add_wall_decor()
	
func add_cracks():
	var crack_count: int = floor(randf_range(0.1, 0.2) * 200)
	for i in crack_count:
		var pos = Vector2i(randi_range(3, 22), randi_range(4, 12))
		tile_map.set_cell(0, pos, 0, crack_tiles.pick_random())

func add_wall_decor():
	if randf() < 0.2:
		var pos_x : int
		if layout & 1:
			pos_x = randi_range(4, 9) if randf() < 0.5 else randi_range(16, 21)
		else:
			pos_x = randi_range(4, 21)
	
		if randf() < 0.5:
			tile_map.set_cell(1, Vector2i(pos_x, 2), 0, Vector2i(4,0))
			tile_map.set_cell(1, Vector2i(pos_x, 3), 0, Vector2i(4,1))
			tile_map.set_cell(0, Vector2i(pos_x, 4), 0, Vector2i(4,2))
		else:
			tile_map.set_cell(1, Vector2i(pos_x, 3), 0, Vector2i(4,3))
			tile_map.set_cell(0, Vector2i(pos_x, 4), 0, Vector2i(4,4))
				

func _on_area_2d_body_entered(body: Node2D) -> void:
	new_room_reached.emit(coords)
	$Area2D.queue_free()
