extends Control

const heart_bar_scene = preload("res://scenes/heart_bar.tscn")


@export var max_health : int
@export var health_per_heart : int = 10

var current_health : float
var num_hearts : int


func initialize(_max_health : int, _current_health : float):
	max_health = _max_health
	current_health = _current_health
	num_hearts = ceil(max_health / health_per_heart)
	for i in num_hearts:
		var heart_bar = heart_bar_scene.instantiate()
		heart_bar.max_value = health_per_heart
		call_deferred("add_child", heart_bar)
	await get_tree().process_frame
	update_health(current_health)

func update_health(_health : float):
	var idx : int = 0
	current_health = _health
	var remaining_health = current_health
	while remaining_health >= health_per_heart:
		get_child(idx).update_value(health_per_heart)
		remaining_health -= health_per_heart
		idx += 1
	
	if remaining_health > 0:
		get_child(idx).update_value(remaining_health)
		idx += 1
	
	if idx < num_hearts:
		for i in range(idx, num_hearts):
			get_child(i).update_value(0)

func adjust_max_health(_max_health : int):
	var new_num_hearts : int =  ceil(float(_max_health) / health_per_heart)
	var diff : int = new_num_hearts - num_hearts
	prints(_max_health, _max_health / health_per_heart, new_num_hearts, diff)
	if diff == 0:
		max_health = _max_health
	elif diff > 0:
		for i in range(diff):
			var heart_bar = heart_bar_scene.instantiate()
			heart_bar.max_value = health_per_heart
			call_deferred("add_child", heart_bar)
	else:
		for i in range(num_hearts - 1, new_num_hearts - 1, -1):
			get_child(i).queue_free()
	max_health = _max_health
	num_hearts = new_num_hearts
	if current_health > max_health:
		current_health = max_health
	await get_tree().process_frame
	update_health(current_health)		
