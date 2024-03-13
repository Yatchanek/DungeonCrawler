extends Enemy

@onready var weapon: Weapon = $Pivot/WeaponPivot/Wand
@onready var weapon_pivot: Marker2D = $Pivot/WeaponPivot
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer


var player_in_range : bool = false


func _ready() -> void:
	super()
	weapon.initialize_damage(unit_data.base_damage)

func attack() -> bool:
	return weapon.attack(attack_type)
	
func _on_detector_body_exited(_body) -> void:
	if !is_dead:
		chase_stop_timer.start()

func _on_attack_sensor_area_entered(area : Area2D) -> void:
	if area is HitBox:
		fsm.transition("AttackState")
		
func _on_attack_cooldown_timer_timeout() -> void:
	enable_attack_sensor()


func _on_chase_stop_timer_timeout() -> void:
	if is_dead:
		return
	if check_if_player_in_sight():
		chase_stop_timer.start()
	else:
		target = null
		player_in_range = false
		if fsm.current_state.name != "HitState":
			fsm.transition("IdleState")

func _on_detector_area_entered(area: Area2D) -> void:
	player_in_range = true


func _on_detector_area_exited(area: Area2D) -> void:

	player_in_range = false
