extends Node
## PlayerInventory - Autoload giữ túi đồ chính của người chơi.
## Các hệ thống khác (khai thác, chiến đấu, crafting) gọi qua đây.

const SLOT_COUNT: int = 20

var inventory: Inventory

func _ready() -> void:
	inventory = Inventory.new(SLOT_COUNT)
	# Reset túi khi bắt đầu game mới.
	GameState.state_reset.connect(_on_new_game)

func _on_new_game() -> void:
	inventory.clear()

## Tiện ích chuyển tiếp.
func add_item(id: StringName, amount: int = 1) -> int:
	return inventory.add_item(id, amount)

func remove_item(id: StringName, amount: int = 1) -> int:
	return inventory.remove_item(id, amount)

func has_item(id: StringName, amount: int = 1) -> bool:
	return inventory.has_item(id, amount)

func count_of(id: StringName) -> int:
	return inventory.count_of(id)

# --- Save/Load (dùng ở Task 13) ---
func to_dict() -> Dictionary:
	return {"slots": inventory.to_array()}

func from_dict(data: Dictionary) -> void:
	inventory.from_array(data.get("slots", []))
