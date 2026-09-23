extends CanvasLayer
## TutorialOverlay - dạy điều khiển theo bước ngay trong Nhà (lần chơi đầu).
## Chỉ chạy khi GameState.tutorial_done == false. Có nút Bỏ qua.
## Phát hiện hành động của người chơi qua PlayerInput để hoàn thành từng bước.

enum Step { MOVE, JUMP, INVENTORY, DONE }

@onready var _root: Control = $Root
@onready var _text: Label = $Root/Panel/VBox/Text
@onready var _skip_button: Button = $Root/Panel/VBox/SkipButton

var _step: int = Step.MOVE
var _active: bool = false
var _move_accum: float = 0.0
var _player: CharacterBody2D
var _inv_was_open: bool = false

const STEP_TEXT := {
	Step.MOVE: "Dùng joystick trái (hoặc A/D) để DI CHUYỂN.",
	Step.JUMP: "Nhấn nút NHẢY (hoặc Space) để nhảy lên.",
	Step.INVENTORY: "Nhấn nút TÚI (hoặc I) để mở túi đồ.",
	Step.DONE: "Xong! Lại gần đồ vật để Tương tác, và ra cửa để khám phá rừng. Chúc may mắn!",
}

func _ready() -> void:
	layer = 25
	if GameState.tutorial_done:
		_root.visible = false
		set_process(false)
		return
	_active = true
	_skip_button.pressed.connect(_finish)
	# Đợi player sẵn sàng để quan sát trạng thái (không tiêu thụ input).
	await get_tree().process_frame
	_player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	_set_step(Step.MOVE)

func _process(delta: float) -> void:
	if not _active:
		return
	match _step:
		Step.MOVE:
			# Quan sát chuyển động thực của player (không tiêu thụ input).
			if _player and absf(_player.velocity.x) > 10.0:
				_move_accum += delta
				if _move_accum > 0.5:
					_set_step(Step.JUMP)
		Step.JUMP:
			# Phát hiện đang bay lên (đã nhảy).
			if _player and not _player.is_on_floor() and _player.velocity.y < -20.0:
				_set_step(Step.INVENTORY)
		Step.INVENTORY:
			# Quan sát action toggle (Input.is_action_just_pressed không tiêu thụ).
			if Input.is_action_just_pressed("toggle_inventory"):
				_set_step(Step.DONE)
		Step.DONE:
			pass

func _set_step(step: int) -> void:
	_step = step
	_text.text = STEP_TEXT[step]
	if step == Step.DONE:
		# Hoàn thành: đánh dấu và tự ẩn sau vài giây.
		GameState.tutorial_done = true
		var t: SceneTreeTimer = get_tree().create_timer(2.5)
		t.timeout.connect(_finish)

func _finish() -> void:
	if not _active:
		return
	_active = false
	GameState.tutorial_done = true
	_root.visible = false
	set_process(false)
