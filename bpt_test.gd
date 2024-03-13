extends Node2D

var root_node : TreeNode





func _ready() -> void:
	root_node = TreeNode.new(Rect2(Vector2(0,0), Vector2(1600, 900)), 1, 1)
	root_node.split()
	traverse(root_node)
	root_node.make_room()
	draw_rooms(root_node)
	draw_path(root_node)

func traverse(node : TreeNode):
	if !node:
		return
	var current_rect : Rect2 = node.content
	var line = Line2D.new()
	line.width = 2
	line.default_color = Color.WHITE
	line.add_point(current_rect.position)
	line.add_point(current_rect.position + Vector2(current_rect.size.x, 0))
	line.add_point(current_rect.position + current_rect.size)
	line.add_point(current_rect.position + Vector2(0, current_rect.size.y))
	line.add_point(current_rect.position)
	add_child(line)

	var label : Label = Label.new()
	label.text = str(node.level)
	label.position = node.content.position + Vector2(node.content.size.x, node.content.size.y) * 0.5
	add_child(label)

	await get_tree().create_timer(0.25).timeout
	
	traverse(node.left)
	traverse(node.right)
	



func make_rooms(node : TreeNode):
	if !node:
		return
	node.left.make_room()
	node.right.make_room()

func draw_rooms(node : TreeNode):
	if !node:
		return
	draw_rooms(node.left)
	draw_rooms(node.right)
	
	var points : PackedVector2Array = []
	points.append(node.room.position)
	points.append(node.room.position + Vector2(node.room.size.x, 0))
	points.append(node.room.position + Vector2(node.room.size))
	points.append(node.room.position + Vector2(0, node.room.size.y))
	
	var poly = Polygon2D.new()
	poly.color = Color.TAN
	poly.polygon = points
	add_child(poly)


func draw_path(node):
	var S : Array = []
	var Q : Array = []
	
	Q.append(node)
	
	while Q.size() > 0:
		node = Q[0]
		Q.pop_front()
		S.append(node)
		
		if node.right:
			Q.append(node.right)
			Q.append(node.left)
	
	print(S.size())
	while S.size() > 1:
		node = S.pop_back()
		var node1 : TreeNode = S.pop_back()
		
		var line = Line2D.new()
		line.default_color = Color.RED
		line.default_color.r -= node.level * 0.1
		line.width = 20
		line.add_point(node.content.position + Vector2(node.content.size.x, node.content.size.y) * 0.5)
		line.add_point(node1.content.position + Vector2(node1.content.size.x, node1.content.size.y) * 0.5)
		add_child(line)


