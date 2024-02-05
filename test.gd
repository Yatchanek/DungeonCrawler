extends Node2D

var points : Array = []
var del_points : Array = []

var graph : AStar2D = AStar2D.new()
var mst_graph : AStar2D = AStar2D.new()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			get_tree().reload_current_scene()

func _draw() -> void:
	for point in mst_graph.get_point_ids():
		draw_circle(mst_graph.get_point_position(point), 5, Color.WHITE)
		
	for point in mst_graph.get_point_ids():
		for dest in mst_graph.get_point_connections(point):
			draw_line(mst_graph.get_point_position(point), mst_graph.get_point_position(dest), Color.WHITE, 2.0)
		
func _ready() -> void:
	create_points()
	del_points = Array(Geometry2D.triangulate_delaunay(points))
	for i in del_points.size() / 3:
		var p1 : int = del_points.pop_front()
		var p2 : int = del_points.pop_front()
		var p3 : int = del_points.pop_front()
		
		graph.connect_points(p1, p2)
		graph.connect_points(p1, p3)
		graph.connect_points(p2, p3)
	find_mst_2()

	for point in graph.get_point_ids():
		for dest in graph.get_point_connections(point):
			if dest > point and randf() < 0.15:
				var p1 : int = mst_graph.get_closest_point(graph.get_point_position(point))
				var p2 : int = mst_graph.get_closest_point(graph.get_point_position(dest))
				if !mst_graph.are_points_connected(p1, p2):
					mst_graph.connect_points(p1, p2)

	queue_redraw()


func find_mst_2():
	var idx = randi() % points.size()
	var p = points.pop_at(idx)
	mst_graph.add_point(mst_graph.get_available_point_id(), p)
	
	while points.size() > 0:
		var min_dist : float = INF
		var candidate_pos : Vector2
		var current_point
		for point in mst_graph.get_point_ids():
			var current_pos = mst_graph.get_point_position(point)
			
			for candidate_point in points:
				if current_pos.distance_squared_to(candidate_point) < min_dist:
					min_dist = current_pos.distance_squared_to(candidate_point)
					candidate_pos = candidate_point
					current_point = current_pos

			
		var n : int = mst_graph.get_available_point_id()
		mst_graph.add_point(n, candidate_pos)
		mst_graph.connect_points(mst_graph.get_closest_point(current_point), n)
		points.erase(candidate_pos)

			
func find_mst():
	var idx = randi() % points.size()
	var visited_points : Array = []
	visited_points.append(points[idx])
	mst_graph.add_point(mst_graph.get_available_point_id(), points[idx])
	
	while visited_points.size() != graph.get_point_count():
		var min_dist : float = INF
		var candidate : int = -1
		var current_point : int
		var pos_1 : Vector2
		for point in mst_graph.get_point_ids():
			pos_1 = mst_graph.get_point_position(point)
			for dest in graph.get_point_connections(point):
				var pos_2 = graph.get_point_position(dest)
				if pos_1.distance_squared_to(pos_2) < min_dist:
					min_dist = pos_1.distance_squared_to(pos_2)
					candidate = dest
					current_point = point

		var n = mst_graph.get_available_point_id()
		mst_graph.add_point(n, graph.get_point_position(candidate))
		
		mst_graph.connect_points(mst_graph.get_closest_point(pos_1), n)	
		graph.disconnect_points(graph.get_closest_point(pos_1), candidate)
		visited_points.append(graph.get_point_position(candidate))
	

	
func create_points():
	for i in range(30):
		var p := Vector2(randf_range(50, 1550), randf_range(50, 900))
		points.append(p)
		graph.add_point(graph.get_available_point_id(),p)
	
