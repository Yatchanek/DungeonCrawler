extends CanvasLayer

@onready var health_display: HBoxContainer = $MarginContainer/VBoxContainer/HealthDisplay
@onready var charge_bar: TextureProgressBar = $MarginContainer/VBoxContainer/ChargeBar

func update_health(health : float):
	health_display.update_health(health)
	
func update_charge_amount(amount : float):
	charge_bar.value = amount
