extends Button
class_name TouchActionButton
## Nút hành động cảm ứng. Gắn vào một action và gọi PlayerInput tương ứng khi nhấn.
## Dùng Button (hiển thị text + nền theme sẵn, không cần asset).

enum Action { JUMP, ATTACK, RANGED, INTERACT, INVENTORY }

@export var action: Action = Action.JUMP

func _ready() -> void:
	# button_down kích hoạt ngay khi ngón chạm xuống (phản hồi nhanh cho game).
	button_down.connect(_on_pressed)

func _on_pressed() -> void:
	match action:
		Action.JUMP:
			PlayerInput.press_touch_jump()
		Action.ATTACK:
			PlayerInput.press_touch_attack()
		Action.RANGED:
			PlayerInput.press_touch_ranged()
		Action.INTERACT:
			PlayerInput.press_touch_interact()
		Action.INVENTORY:
			# Gửi InputEventAction thật để _unhandled_input của InventoryUI bắt được.
			var ev := InputEventAction.new()
			ev.action = "toggle_inventory"
			ev.pressed = true
			Input.parse_input_event(ev)
