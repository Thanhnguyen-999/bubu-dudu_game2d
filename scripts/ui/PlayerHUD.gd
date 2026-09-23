extends CanvasLayer
## PlayerHUD - hiển thị thanh máu người chơi. Tìm player trong scene và lắng nghe.

@onready var _bar: ProgressBar = $Root/HealthBar
@onready var _label: Label = $Root/HealthBar/Label
@onready var _save_button: Button = $Root/SaveButton
@onready var _toast: Label = $Root/Toast

func _ready() -> void:
	layer = 15
	_save_button.pressed.connect(_on_save_pressed)
	# Đợi 1 frame để player chắc chắn đã vào cây scene.
	await get_tree().process_frame
	_bind_player()

func _on_save_pressed() -> void:
	var ok: bool = SaveManager.save_game()
	_show_toast("Đã lưu game!" if ok else "Lưu thất bại!")

func _show_toast(text: String) -> void:
	_toast.text = text
	_toast.modulate.a = 1.0
	var tween: Tween = create_tween()
	tween.tween_interval(0.8)
	tween.tween_property(_toast, "modulate:a", 0.0, 0.8)

func _bind_player() -> void:
	var player: Node = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("health_changed"):
		if not player.health_changed.is_connected(_on_health_changed):
			player.health_changed.connect(_on_health_changed)
	_on_health_changed(GameState.player_health, GameState.player_max_health)

func _on_health_changed(current: int, maximum: int) -> void:
	if _bar:
		_bar.max_value = maximum
		_bar.value = current
	if _label:
		_label.text = "%d / %d" % [current, maximum]
