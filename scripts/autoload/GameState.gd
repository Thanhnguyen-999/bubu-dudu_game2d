extends Node
## GameState - Autoload singleton chứa dữ liệu game xuyên suốt các scene.
## Là nguồn dữ liệu trung tâm để save/load và chia sẻ trạng thái giữa các map.

signal state_reset

# --- Cờ tiến trình chơi ---
var intro_seen: bool = false      # Đã xem intro cutscene chưa
var tutorial_done: bool = false   # Đã hoàn thành tutorial chưa

# --- Trạng thái người chơi ---
var player_health: int = 100
var player_max_health: int = 100

# --- Vị trí hiện tại của người chơi trong thế giới ---
var current_map: String = "House"          # Tên map hiện tại
var player_spawn_point: String = "default" # Điểm spawn khi vào map

# --- Map đã mở khóa (phố cổ + rừng mở sẵn; map khác mở qua quest) ---
var unlocked_maps: Array = ["House", "PhoCoHoaLu", "Rung"]

# --- Trạng thái tài nguyên đã khai thác theo map: {map_key: {node_id: true}} ---
var harvested_resources: Dictionary = {}

## Khởi tạo trạng thái mới hoàn toàn (New Game).
func reset_new_game() -> void:
	intro_seen = false
	tutorial_done = false
	player_health = 100
	player_max_health = 100
	current_map = "House"
	player_spawn_point = "default"
	unlocked_maps = ["House", "PhoCoHoaLu", "Rung"]
	harvested_resources = {}
	state_reset.emit()

## Gom dữ liệu core thành dictionary để lưu (các hệ thống khác sẽ mở rộng).
func to_dict() -> Dictionary:
	return {
		"intro_seen": intro_seen,
		"tutorial_done": tutorial_done,
		"player_health": player_health,
		"player_max_health": player_max_health,
		"current_map": current_map,
		"player_spawn_point": player_spawn_point,
		"unlocked_maps": unlocked_maps.duplicate(),
		"harvested_resources": harvested_resources.duplicate(true),
	}

## Nạp dữ liệu core từ dictionary khi load game.
func from_dict(data: Dictionary) -> void:
	intro_seen = data.get("intro_seen", false)
	tutorial_done = data.get("tutorial_done", false)
	player_health = int(data.get("player_health", 100))
	player_max_health = int(data.get("player_max_health", 100))
	current_map = data.get("current_map", "House")
	player_spawn_point = data.get("player_spawn_point", "default")
	unlocked_maps = data.get("unlocked_maps", ["House", "PhoCoHoaLu", "Rung"]).duplicate()
	harvested_resources = data.get("harvested_resources", {}).duplicate(true)
