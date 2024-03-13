extends Node

@onready var hud: CanvasLayer = $HUD
@onready var health_display: HBoxContainer = $HUD/MarginContainer/VBoxContainer/HealthDisplay


var player : Player

func _ready() -> void:
	health_display.initialize(player.max_hp, player.current_hp)
	hud.update_charge_amount(player.weapon_charge_amount / player.FULL_CHARGE * 100)

func _on_player_ready(_player : Player):
	player = _player

func _on_player_health_changed(health : float):
	hud.update_health(health)

func _on_player_charge_amount_changed(amount : float):
	hud.update_charge_amount(amount)
