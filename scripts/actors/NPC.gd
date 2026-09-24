extends Interactable
class_name NPC
## NPC trò chuyện. Tương tác -> mở DialogueUI hiển thị chuỗi thoại.
## Text do bạn chỉnh sau qua @export npc_name + lines.

@export var npc_name: String = "Dân làng"
@export_multiline var lines: Array[String] = ["Xin chào!"]

func _on_interact(_player: Node) -> void:
	var ui: Node = get_tree().get_first_node_in_group("dialogue_ui")
	if ui and ui.has_method("start"):
		ui.start(npc_name, lines)
	else:
		push_warning("[NPC] Không tìm thấy DialogueUI trong scene.")
