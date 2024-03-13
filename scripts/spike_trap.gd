extends HurtEntity
class_name Trap

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	has_knockback = false
	initialize_damage(randi_range(1, 3))

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area is HitBox:
		area.target.take_damage(self)


func _on_detector_body_entered(_body: CharacterBody2D) -> void:
	animation_player.play("Launch")
