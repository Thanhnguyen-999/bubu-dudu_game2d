extends Sprite2D
## Mây trôi ngang chậm. Khi ra khỏi biên phải thì vòng lại biên trái.

@export var speed: float = 14.0        # px/giây
@export var wrap_left: float = -300.0
@export var wrap_right: float = 1700.0

func _process(delta: float) -> void:
	position.x += speed * delta
	if position.x > wrap_right:
		position.x = wrap_left
