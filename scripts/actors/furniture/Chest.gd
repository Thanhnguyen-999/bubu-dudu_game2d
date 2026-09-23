extends Interactable
class_name Chest
## Rương - mở UI chuyển đồ túi <-> rương.
## Tìm ChestUI trong scene qua group "chest_ui".

func _on_interact(_player: Node) -> void:
	var ui: Node = get_tree().get_first_node_in_group("chest_ui")
	if ui and ui.has_method("open"):
		ui.open()
	else:
		push_warning("[Chest] Không tìm thấy ChestUI trong scene.")
