extends Interactable
class_name Bed
## Giường - ngủ để LƯU GAME + hồi đầy máu. Hiện thông báo ngắn.

func _on_interact(player: Node) -> void:
	# Hồi đầy máu.
	if player and player.has_method("heal"):
		player.heal(GameState.player_max_health)
	GameState.player_health = GameState.player_max_health
	# Lưu game.
	var ok: bool = SaveManager.save_game()
	_show_toast("Đã lưu game & hồi máu!" if ok else "Lưu thất bại!")

func _show_toast(text: String) -> void:
	var toast: Label = Label.new()
	toast.text = text
	toast.add_theme_font_size_override("font_size", 28)
	toast.position = Vector2(-60, -90)
	toast.z_index = 100
	add_child(toast)
	var tween: Tween = create_tween()
	tween.tween_property(toast, "position:y", -130.0, 1.2)
	tween.parallel().tween_property(toast, "modulate:a", 0.0, 1.2)
	tween.tween_callback(toast.queue_free)
