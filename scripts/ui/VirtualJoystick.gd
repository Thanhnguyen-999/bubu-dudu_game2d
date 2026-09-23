extends Control
class_name TouchJoystick
## Joystick ảo cảm ứng.
## Kéo trong vùng base sinh trục ngang [-1, 1] đẩy vào PlayerInput.set_touch_move_axis.
## Chỉ dùng trục X cho game side-scrolling (trục Y bỏ qua để đơn giản).
##
## Cấu trúc scene mong đợi:
##   VirtualJoystick (Control)  <- script này
##     Base   (TextureRect/Control) - vòng nền cố định
##       Knob (TextureRect/Control) - núm di chuyển theo ngón tay

## Bán kính tối đa knob rời khỏi tâm (px). Vượt ra sẽ bị kẹp lại.
@export var max_radius: float = 70.0
## Vùng deadzone tương đối (0..1) để tránh trôi nhẹ.
@export var deadzone: float = 0.15

@onready var base: Control = $Base
@onready var knob: Control = $Base/Knob

var _touch_index: int = -1     # ngón tay đang điều khiển (-1 = không có)

func _ready() -> void:
	_reset_knob()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		# Chỉ nhận nếu chạm bên trong bán kính base.
		if _touch_index == -1 and _is_inside(event.position):
			_touch_index = event.index
			_update_from_position(event.position)
			accept_event()
	else:
		if event.index == _touch_index:
			_release()
			accept_event()

func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index == _touch_index:
		_update_from_position(event.position)
		accept_event()

## Kiểm tra vị trí (local trong Control) có nằm trong vùng base không.
func _is_inside(local_pos: Vector2) -> bool:
	var center_local: Vector2 = base.position + base.size * 0.5
	return local_pos.distance_to(center_local) <= max_radius * 1.4

func _update_from_position(local_pos: Vector2) -> void:
	var center_local: Vector2 = base.position + base.size * 0.5
	var offset: Vector2 = local_pos - center_local
	if offset.length() > max_radius:
		offset = offset.normalized() * max_radius
	knob.position = base.position + base.size * 0.5 + offset - knob.size * 0.5

	var axis_x: float = offset.x / max_radius
	if absf(axis_x) < deadzone:
		axis_x = 0.0
	PlayerInput.set_touch_move_axis(axis_x)

func _release() -> void:
	_touch_index = -1
	_reset_knob()
	PlayerInput.set_touch_move_axis(0.0)

func _reset_knob() -> void:
	if is_instance_valid(knob) and is_instance_valid(base):
		knob.position = base.position + base.size * 0.5 - knob.size * 0.5
