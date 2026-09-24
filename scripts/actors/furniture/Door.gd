extends Interactable
class_name Door
## Cổng/cửa chuyển map. Dùng SceneManager.goto_map để sang map đích.
##
## Nếu require_unlock = true, cổng chỉ hoạt động khi target_map đã mở khóa
## (qua QuestManager). Chưa mở -> hiện prompt khóa và không chuyển.

## Map key đích (khớp SceneManager.MAP_PATHS), VD "PhoCoHoaLu", "House".
@export var target_map: String = "PhoCoHoaLu"
## Spawn point ở map đích.
@export var target_spawn: String = "from_house"
## Cổng có cần map được mở khóa trước không.
@export var require_unlock: bool = false
## Prompt khi bị khóa.
@export var locked_prompt: String = "Bị khóa (làm nhiệm vụ)"

var _base_prompt: String = ""

func _ready() -> void:
	super._ready()
	_base_prompt = prompt_text
	if require_unlock:
		QuestManager.map_unlocked.connect(_on_map_unlocked)
		_refresh_lock()

func _refresh_lock() -> void:
	if not require_unlock:
		return
	var unlocked: bool = GameState.unlocked_maps.has(target_map)
	prompt_text = _base_prompt if unlocked else locked_prompt

func _on_map_unlocked(_map_key: StringName) -> void:
	_refresh_lock()

func _on_interact(_player: Node) -> void:
	if require_unlock and not GameState.unlocked_maps.has(target_map):
		return  # còn khóa
	SceneManager.goto_map(target_map, target_spawn)
