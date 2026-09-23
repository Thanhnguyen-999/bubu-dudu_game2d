extends Control
## MainMenu - menu chính: New Game / Continue / Settings / Quit.
##
## Điều hướng New Game sẽ được nối lại qua Intro (Task 11) -> Tutorial (Task 12)
## -> House (Task 4). Tạm thời tới scene gameplay có sẵn.
## Continue bị disable cho tới khi có save (Task 13).

# New Game -> Intro cutscene (Intro xong -> Tutorial/House).
const INTRO_SCENE: String = "res://scenes/boot/IntroCutscene.tscn"

@onready var continue_button: Button = $Panel/Buttons/ContinueButton
@onready var settings_panel: Control = $SettingsPanel

func _ready() -> void:
	# Continue chỉ bật khi có file save (nối ở Task 13).
	continue_button.disabled = not _has_save()
	settings_panel.visible = false

func _has_save() -> bool:
	return SaveManager.has_save()

func _on_new_game_pressed() -> void:
	GameState.reset_new_game()
	SceneManager.goto_scene(INTRO_SCENE)

func _on_continue_pressed() -> void:
	# Nạp save rồi vào thẳng map đã lưu (bỏ qua intro/tutorial).
	if SaveManager.load_game():
		SceneManager.goto_map(GameState.current_map, GameState.player_spawn_point)

func _on_settings_pressed() -> void:
	settings_panel.visible = true

func _on_settings_close_pressed() -> void:
	settings_panel.visible = false

func _on_quit_pressed() -> void:
	get_tree().quit()

## --- Settings: âm lượng master ---
func _on_volume_changed(value: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index("Master")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(clampf(value, 0.0001, 1.0)))
