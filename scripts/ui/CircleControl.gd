extends Control
class_name CircleControl
## Vẽ một hình tròn bán trong suốt lấp đầy vùng Control.
## Dùng làm nền joystick / núm / nút cảm ứng mà không cần asset ảnh.

@export var fill_color: Color = Color(1, 1, 1, 0.25)
@export var outline_color: Color = Color(1, 1, 1, 0.55)
@export var outline_width: float = 3.0

func _draw() -> void:
	var center: Vector2 = size * 0.5
	var radius: float = minf(size.x, size.y) * 0.5 - outline_width
	draw_circle(center, radius, fill_color)
	# Viền: vẽ bằng cung tròn.
	draw_arc(center, radius, 0.0, TAU, 48, outline_color, outline_width, true)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
