extends Interactable
class_name CraftingTable
## Bàn chế tạo - mở UI crafting. Tìm CraftingUI trong scene qua group "crafting_ui".

func _on_interact(_player: Node) -> void:
	var ui: Node = get_tree().get_first_node_in_group("crafting_ui")
	if ui and ui.has_method("open"):
		ui.open()
	else:
		push_warning("[CraftingTable] Không tìm thấy CraftingUI trong scene.")
