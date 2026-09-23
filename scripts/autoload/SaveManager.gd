extends Node
## SaveManager - Autoload lưu/nạp game bằng JSON tại user://savegame.json.
## Gom dữ liệu từ GameState, PlayerInventory, ChestStorage, QuestManager.

signal game_saved
signal game_loaded

const SAVE_PATH: String = "user://savegame.json"
const SAVE_VERSION: int = 1

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

## Gom toàn bộ trạng thái và ghi ra file JSON. Trả về true nếu thành công.
func save_game() -> bool:
	var data: Dictionary = {
		"version": SAVE_VERSION,
		"game_state": GameState.to_dict(),
		"player_inventory": PlayerInventory.to_dict(),
		"chest": ChestStorage.to_dict(),
		"quests": QuestManager.to_dict(),
	}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: không mở được file để ghi: %s" % SAVE_PATH)
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	game_saved.emit()
	return true

## Đọc file save và nạp vào các hệ thống. Trả về true nếu thành công.
func load_game() -> bool:
	if not has_save():
		return false
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: không mở được file để đọc: %s" % SAVE_PATH)
		return false
	var text: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("SaveManager: file save hỏng.")
		return false
	var data: Dictionary = parsed

	GameState.from_dict(data.get("game_state", {}))
	PlayerInventory.from_dict(data.get("player_inventory", {}))
	ChestStorage.from_dict(data.get("chest", {}))
	QuestManager.from_dict(data.get("quests", {}))
	game_loaded.emit()
	return true

## Xóa save (dùng nếu cần New Game sạch).
func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)
