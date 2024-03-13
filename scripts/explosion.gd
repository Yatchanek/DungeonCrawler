extends Sprite2D

@onready var collision_shape_2d: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var hurtbox: HurtBox = $Hurtbox

var caused_by : HurtEntity
var explosion_radius : float = 64

func _ready() -> void:
	hurtbox.attacker = caused_by
	var tw = create_tween()
	tw.finished.connect(queue_free)
	tw.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_parallel()
	tw.tween_property(self, "scale", Vector2.ONE, 0.25)
	tw.tween_property(collision_shape_2d.shape, "radius", explosion_radius, 0.25)
	tw.chain().tween_interval(0.15)
