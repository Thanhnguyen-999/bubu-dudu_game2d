extends Node
## ChestStorage - Autoload giữ nội dung rương lưu trữ trong nhà.
## Tách khỏi túi người chơi để tồn tại xuyên scene và save riêng.

const SLOT_COUNT: int = 20

var inventory: Inventory

func _ready() -> void:
	inventory = Inventory.new(SLOT_COUNT)
	GameState.state_reset.connect(_on_new_game)

func _on_new_game() -> void:
	inventory.clear()

# --- Save/Load (Task 13) ---
func to_dict() -> Dictionary:
	return {"slots": inventory.to_array()}

func from_dict(data: Dictionary) -> void:
	inventory.from_array(data.get("slots", []))
