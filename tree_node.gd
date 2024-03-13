extends Resource
class_name TreeNode

const min_size : int = 200
var parent : TreeNode
var left : TreeNode
var right : TreeNode
var content : Rect2
var room : Rect2
var level : int
var value : int 


func _init(_content : Rect2, _level : int, _value : int) -> void:
	content = _content
	level = _level
	value = _value
	
func split():
	var dir : int
	#if content.size.x < min_size * 2 or content.size.y < min_size * 2:
		#return
	if content.size.x < min_size * 2 and content.size.y >= min_size * 2:
		dir = 0
	elif content.size.y < min_size * 2 and content.size.x >= min_size * 2:	
		dir = 1
	elif content.size.x >= min_size * 2 and content.size.y >= min_size * 2:
		dir = randi() % 2
	else:
		return
				
	var offset = randf_range(0.45, 0.55)
	var rect_1 : Rect2
	var rect_2 : Rect2
	if dir == 0:
		rect_1 = Rect2(content.position, Vector2(content.size.x, content.size.y * offset))
		rect_2 = Rect2(Vector2(content.position.x, content.position.y + rect_1.size.y), Vector2(content.size.x, content.size.y - rect_1.size.y))
	else:
		rect_1 = Rect2(content.position, Vector2(content.size.x * offset, content.size.y))
		rect_2 = Rect2(Vector2(content.position.x + rect_1.size.x, content.position.y), Vector2(content.size.x - rect_1.size.x , content.size.y ))
		
	left = TreeNode.new(rect_1, level + 1, value + 1)
	right = TreeNode.new(rect_2, level + 1, value + 2)
	left.split()
	right.split()

func print_self():
	if left:
		left.print_self()
		right.print_self()


func make_room():
	if !left and !right:
		var offset = randf_range(0.7, 0.9)
		var pos : Vector2 = content.position + Vector2(randf_range(0, content.size.x * (1 - offset)), randf_range(0, content.size.y * (1 - offset)))
		room = Rect2(pos, content.size * offset)

	else:
		left.make_room()
		right.make_room()
