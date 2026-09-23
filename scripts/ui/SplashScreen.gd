extends Control
## SplashScreen - hiện logo game, fade in/out rồi tự chuyển sang MainMenu.
## Chạm màn hình để bỏ qua nhanh.

const MAIN_MENU_PATH: String = "res://scenes/boot/MainMenu.tscn"

@export var hold_time: float = 1.4  # thời gian giữ logo (giây)

var _done: bool = false

func _ready() -> void:
	modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	tween.tween_interval(hold_time)
	tween.tween_callback(_go_to_menu)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_go_to_menu()
	elif event is InputEventKey and event.pressed:
		_go_to_menu()

func _go_to_menu() -> void:
	if _done:
		return
	_done = true
	SceneManager.goto_scene(MAIN_MENU_PATH)
