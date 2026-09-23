extends Node
class_name HealthComponent
## Component máu tái sử dụng cho enemy (và có thể player). Gắn làm node con.

signal damaged(amount: int, current: int)
signal died
signal health_changed(current: int, maximum: int)

@export var max_health: int = 10

var current_health: int = 0

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	if current_health <= 0:
		return
	current_health = maxi(0, current_health - maxi(0, amount))
	damaged.emit(amount, current_health)
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		died.emit()

func heal(amount: int) -> void:
	current_health = mini(max_health, current_health + maxi(0, amount))
	health_changed.emit(current_health, max_health)

func is_alive() -> bool:
	return current_health > 0
