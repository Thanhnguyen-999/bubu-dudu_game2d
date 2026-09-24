extends CanvasLayer
## DialogueUI - hộp thoại dưới màn hình cho NPC.
## start(name, lines) mở hội thoại; chạm/nút Tiếp/phím để qua câu; hết thì đóng.
## Khóa input gameplay (PlayerInput.input_locked) khi đang mở.

@onready var _root: Control = $Root
@onready var _name_label: Label = $Root/Box/VBox/NameLabel
@onready var _text_label: Label = $Root/Box/VBox/TextLabel
@onready var _next_button: Button = $Root/Box/VBox/NextButton

var _lines: Array = []
var _index: int = 0
var _open: bool = false

func _ready() -> void:
	layer = 24
	_root.visible = false
	_next_button.pressed.connect(_advance)

## Bắt đầu hội thoại với tên NPC và danh sách câu thoại.
func start(npc_name: String, lines: Array) -> void:
	if lines.is_empty():
		return
	_lines = lines
	_index = 0
	_open = true
	_name_label.text = npc_name
	_root.visible = true
	PlayerInput.input_locked = true
	_show_current()

func _show_current() -> void:
	_text_label.text = str(_lines[_index])
	_next_button.text = "Tiếp »" if _index < _lines.size() - 1 else "Đóng"

func _advance() -> void:
	if not _open:
		return
	_index += 1
	if _index >= _lines.size():
		_close()
	else:
		_show_current()

func _close() -> void:
	_open = false
	_root.visible = false
	PlayerInput.input_locked = false

## Cho phép chạm bất kỳ đâu / phím tương tác để qua câu (ngoài nút Tiếp).
func _unhandled_input(event: InputEvent) -> void:
	if not _open:
		return
	var advance: bool = false
	if event is InputEventScreenTouch and event.pressed:
		advance = true
	elif event is InputEventMouseButton and event.pressed:
		advance = true
	elif event.is_action_pressed("interact") or event.is_action_pressed("jump"):
		advance = true
	if advance:
		_advance()
		get_viewport().set_input_as_handled()
