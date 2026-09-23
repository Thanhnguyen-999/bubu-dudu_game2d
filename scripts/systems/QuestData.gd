extends Resource
class_name QuestData
## Nhiệm vụ data-driven (.tres). MVP hỗ trợ 2 loại mục tiêu:
##  - COLLECT: thu thập đủ số lượng 1 item (target_id).
##  - KILL: hạ đủ số lượng thú.

enum ObjectiveType { COLLECT, KILL }

@export var quest_id: StringName = &""
@export var title: String = ""
@export_multiline var description: String = ""
@export var objective_type: ObjectiveType = ObjectiveType.COLLECT
## Với COLLECT: id item cần thu thập. Với KILL: có thể để trống (mọi loại thú).
@export var target_id: StringName = &""
@export var required_amount: int = 1
## Khi hoàn thành, mở khóa map key này (khớp SceneManager.MAP_PATHS). Để trống nếu không.
@export var unlock_map: StringName = &""
