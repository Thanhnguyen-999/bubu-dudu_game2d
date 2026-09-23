extends Node
## QuestManager - Autoload theo dõi quest và mở khóa map.
## Nạp quest từ data/quests/. Nhận sự kiện:
##  - report_kill(): khi hạ 1 thú.
##  - COLLECT quest tự kiểm qua PlayerInventory.count_of.
##
## Trạng thái tiến độ + map đã mở khóa lưu trong GameState (save Task 13).

signal quest_updated(quest: QuestData, progress: int, completed: bool)
signal quest_completed(quest: QuestData)
signal map_unlocked(map_key: StringName)

const QUESTS_DIR: String = "res://data/quests"

var _quests: Array[QuestData] = []
## quest_id -> progress (int)
var _progress: Dictionary = {}
## quest_id -> completed (bool)
var _completed: Dictionary = {}

func _ready() -> void:
	_load_all()
	GameState.state_reset.connect(_on_new_game)
	# Theo dõi thay đổi túi để cập nhật quest COLLECT.
	PlayerInventory.inventory.changed.connect(_on_inventory_changed)

func _load_all() -> void:
	var dir: DirAccess = DirAccess.open(QUESTS_DIR)
	if dir == null:
		push_warning("QuestManager: không mở được %s" % QUESTS_DIR)
		return
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and _is_res(file_name):
			var clean: String = file_name.trim_suffix(".remap")
			var res: Resource = load("%s/%s" % [QUESTS_DIR, clean])
			if res is QuestData:
				_quests.append(res as QuestData)
		file_name = dir.get_next()
	dir.list_dir_end()

func _is_res(file_name: String) -> bool:
	return file_name.ends_with(".tres") or file_name.ends_with(".res") \
		or file_name.ends_with(".tres.remap") or file_name.ends_with(".res.remap")

func _on_new_game() -> void:
	_progress.clear()
	_completed.clear()

func all_quests() -> Array[QuestData]:
	return _quests

func get_progress(quest: QuestData) -> int:
	return int(_progress.get(String(quest.quest_id), 0))

func is_completed(quest: QuestData) -> bool:
	return bool(_completed.get(String(quest.quest_id), false))

func is_map_unlocked(map_key: StringName) -> bool:
	return GameState.unlocked_maps.has(String(map_key))

# --- Sự kiện gameplay ---

## Gọi khi hạ 1 thú (Enemy._on_died).
func report_kill() -> void:
	for quest in _quests:
		if quest.objective_type == QuestData.ObjectiveType.KILL and not is_completed(quest):
			var p: int = get_progress(quest) + 1
			_progress[String(quest.quest_id)] = p
			_check_complete(quest, p)

func _on_inventory_changed() -> void:
	for quest in _quests:
		if quest.objective_type == QuestData.ObjectiveType.COLLECT and not is_completed(quest):
			var have: int = PlayerInventory.count_of(quest.target_id)
			var p: int = mini(have, quest.required_amount)
			if p != get_progress(quest):
				_progress[String(quest.quest_id)] = p
				_check_complete(quest, p)

func _check_complete(quest: QuestData, progress: int) -> void:
	var done: bool = progress >= quest.required_amount
	quest_updated.emit(quest, progress, done)
	if done and not is_completed(quest):
		_completed[String(quest.quest_id)] = true
		if quest.unlock_map != &"":
			_unlock_map(quest.unlock_map)
		quest_completed.emit(quest)

func _unlock_map(map_key: StringName) -> void:
	if not GameState.unlocked_maps.has(String(map_key)):
		GameState.unlocked_maps.append(String(map_key))
		map_unlocked.emit(map_key)

# --- Save/Load (Task 13) ---
func to_dict() -> Dictionary:
	return {
		"progress": _progress.duplicate(),
		"completed": _completed.duplicate(),
	}

func from_dict(data: Dictionary) -> void:
	_progress = data.get("progress", {}).duplicate()
	_completed = data.get("completed", {}).duplicate()
	# Phát lại cập nhật để UI đồng bộ.
	for quest in _quests:
		quest_updated.emit(quest, get_progress(quest), is_completed(quest))
