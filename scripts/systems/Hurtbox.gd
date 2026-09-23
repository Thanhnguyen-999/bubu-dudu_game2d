extends Area2D
class_name Hurtbox
## Vùng nhận sát thương. Chuyển tiếp take_hit() tới node cha (owner logic).
## Dùng để hitbox/projectile của player quét trúng và gây damage cho chủ sở hữu.

## Node xử lý sát thương thật (mặc định là cha). Phải có method take_hit(power, source).
@export_node_path("Node") var target_path: NodePath

func take_hit(power: int, source: Node = null) -> void:
	var target: Node = get_node_or_null(target_path) if target_path != NodePath() else get_parent()
	if target and target.has_method("take_hit"):
		target.take_hit(power, source)
