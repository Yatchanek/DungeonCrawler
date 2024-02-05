extends Sprite2D

func _ready() -> void:
	var tw = create_tween()
	tw.finished.connect(queue_free)
	tw.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.25)
