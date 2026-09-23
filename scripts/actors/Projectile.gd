extends Area2D
class_name Projectile
## Đạn tầm xa (mũi tên). Bay ngang theo hướng bắn, trúng enemy hurtbox -> take_hit.
## Tự hủy khi trúng, hết tầm, hoặc quá thời gian sống.

@export var speed: float = 620.0
@export var max_lifetime: float = 2.0

var _dir: int = 1
var _power: int = 3
var _life: float = 0.0
var _spent: bool = false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 16  # layer 5 = enemy_hitbox
	area_entered.connect(_on_area_entered)

## Khởi tạo đạn: vị trí bắt đầu, hướng (1/-1), lực.
func setup(start_pos: Vector2, dir: int, power: int) -> void:
	global_position = start_pos
	_dir = signi(dir) if dir != 0 else 1
	_power = power
	# Xoay hình theo hướng.
	scale.x = float(_dir)

func _physics_process(delta: float) -> void:
	position.x += _dir * speed * delta
	_life += delta
	if _life >= max_lifetime:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if _spent:
		return
	if area.has_method("take_hit"):
		_spent = true
		area.take_hit(_power, self)
		queue_free()
