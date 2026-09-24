extends Node
## PlayerInput - Autoload trừu tượng hóa nguồn input.
## Task 1: đọc từ bàn phím (Input Actions).
## Task 2: joystick ảo + nút cảm ứng sẽ ghi đè các giá trị này qua các hàm set_*.
##
## Nhờ lớp trung gian này, Player.gd và các hệ thống khác không cần biết
## input đến từ bàn phím hay màn hình cảm ứng.

# Khi true (VD đang mở hội thoại), mọi input gameplay bị chặn.
var input_locked: bool = false

# Giá trị do touch controls đẩy vào (mặc định 0 / false = không dùng touch).
var _touch_move_axis: float = 0.0
var _touch_jump: bool = false
var _touch_jump_consumed: bool = true
var _touch_attack: bool = false
var _touch_attack_consumed: bool = true
var _touch_ranged: bool = false
var _touch_ranged_consumed: bool = true
var _touch_interact: bool = false
var _touch_interact_consumed: bool = true

## Trục di chuyển ngang [-1, 1]. Ưu tiên touch nếu đang có tác động.
func get_move_axis() -> float:
	if input_locked:
		return 0.0
	if absf(_touch_move_axis) > 0.01:
		return clampf(_touch_move_axis, -1.0, 1.0)
	return Input.get_axis("move_left", "move_right")

## Nhảy (edge-triggered): true đúng 1 frame khi vừa nhấn.
func is_jump_pressed() -> bool:
	if input_locked:
		return false
	if Input.is_action_just_pressed("jump"):
		return true
	if _touch_jump and not _touch_jump_consumed:
		_touch_jump_consumed = true
		return true
	return false

## Tấn công cận chiến (edge-triggered).
func is_attack_pressed() -> bool:
	if input_locked:
		return false
	if Input.is_action_just_pressed("attack"):
		return true
	if _touch_attack and not _touch_attack_consumed:
		_touch_attack_consumed = true
		return true
	return false

## Tấn công tầm xa (edge-triggered).
func is_ranged_pressed() -> bool:
	if input_locked:
		return false
	if Input.is_action_just_pressed("ranged_attack"):
		return true
	if _touch_ranged and not _touch_ranged_consumed:
		_touch_ranged_consumed = true
		return true
	return false

## Tương tác (edge-triggered).
func is_interact_pressed() -> bool:
	if input_locked:
		return false
	if Input.is_action_just_pressed("interact"):
		return true
	if _touch_interact and not _touch_interact_consumed:
		_touch_interact_consumed = true
		return true
	return false

# --- API cho touch controls (Task 2) ---

func set_touch_move_axis(value: float) -> void:
	_touch_move_axis = value

func press_touch_jump() -> void:
	_touch_jump = true
	_touch_jump_consumed = false

func press_touch_attack() -> void:
	_touch_attack = true
	_touch_attack_consumed = false

func press_touch_ranged() -> void:
	_touch_ranged = true
	_touch_ranged_consumed = false

func press_touch_interact() -> void:
	_touch_interact = true
	_touch_interact_consumed = false
