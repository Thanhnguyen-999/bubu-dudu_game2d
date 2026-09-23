extends Control
## IntroCutscene - trình chiếu chuỗi slide cốt truyện.
## Chạm/nút để qua slide, nút Skip bỏ qua toàn bộ. Xong -> Tutorial (Task 12) hoặc House.
##
## Chỉ chạy khi New Game lần đầu (GameState.intro_seen=false). Continue bỏ qua.

# Đích sau intro. Task 12 sẽ đổi sang TutorialRoom nếu tutorial chưa xong.
const NEXT_MAP: StringName = &"House"

## Nội dung slide (mỗi phần tử là 1 đoạn text).
const SLIDES: Array[String] = [
	"Ngày xửa ngày xưa, Bubu và Dudu sống trong một ngôi nhà nhỏ ven rừng...",
	"Một buổi sáng, kho lương thực trống trơn. Rừng ngoài kia đầy gỗ, khoáng và thú dữ.",
	"Đã đến lúc ra ngoài khám phá: chặt cây, đào khoáng, săn thú và mở ra những vùng đất mới.",
	"Hành trình của bạn bắt đầu từ đây. Chúc may mắn!",
]

@onready var _text: Label = $Center/SlideText
@onready var _hint: Label = $Center/TapHint

var _index: int = 0
var _busy: bool = false

func _ready() -> void:
	_index = 0
	_show_slide(0)

func _unhandled_input(event: InputEvent) -> void:
	var advance: bool = false
	if event is InputEventScreenTouch and event.pressed:
		advance = true
	elif event is InputEventMouseButton and event.pressed:
		advance = true
	elif event is InputEventKey and event.pressed and not event.echo:
		advance = true
	if advance:
		_next()

func _next() -> void:
	if _busy:
		return
	_index += 1
	if _index >= SLIDES.size():
		_finish()
	else:
		_show_slide(_index)

func _show_slide(i: int) -> void:
	_busy = true
	_text.text = SLIDES[i]
	_text.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(_text, "modulate:a", 1.0, 0.5)
	tween.tween_callback(func() -> void: _busy = false)

func _on_skip_pressed() -> void:
	_finish()

func _finish() -> void:
	GameState.intro_seen = true
	# Task 12 sẽ chèn Tutorial vào đây. Tạm thời vào thẳng nhà.
	SceneManager.goto_map(NEXT_MAP, "default")
