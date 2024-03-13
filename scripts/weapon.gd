extends HurtEntity
class_name Weapon


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var body: Sprite2D = $Body

@export var weapon_pivot : Marker2D

const MAX_SPEED : int = 900
const ACCELERATION : float = 3000.0

var is_busy : bool = false
var is_charging : bool = false
var is_launched : bool = false
var is_ready : bool = true


var explosion_collision_mask : int

func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	explosion_collision_mask = 5

		
func attack(anim_name : String):
	if is_busy or is_charging or !is_ready:
		return false
	animation_player.play(anim_name)
	is_busy = true
	return true

func appear():
	var tw : Tween = create_tween()
	tw.finished.connect(_on_tween_finished)
	tw.tween_interval(0.5)
	tw.tween_property(self, "modulate:a", 1.0, 0.15)


func _on_animation_player_animation_finished(_anim_name: String) -> void:
	is_busy = false

func _on_tween_finished():
	is_ready = true



