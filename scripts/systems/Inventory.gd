extends RefCounted
class_name Inventory
## Kho chứa theo ô có giới hạn. Mỗi ô là {id: StringName, count: int} hoặc rỗng {}.
## Tái sử dụng cho túi người chơi lẫn rương (mỗi cái 1 instance).

signal changed  # phát khi nội dung thay đổi (UI lắng nghe để vẽ lại)

var slot_count: int = 20
## Mảng ô: phần tử là Dictionary rỗng {} hoặc {"id": StringName, "count": int}.
var slots: Array[Dictionary] = []

func _init(count: int = 20) -> void:
	slot_count = count
	_ensure_slots()

func _ensure_slots() -> void:
	slots.resize(slot_count)
	for i in slot_count:
		if slots[i] == null:
			slots[i] = {}

func is_slot_empty(i: int) -> bool:
	return slots[i].is_empty()

## Thêm item vào túi. Trả về số lượng KHÔNG thêm được (0 = thêm hết).
func add_item(id: StringName, amount: int = 1) -> int:
	if amount <= 0:
		return 0
	var item: ItemData = ItemDB.get_item(id)
	if item == null:
		push_warning("Inventory: item không tồn tại: %s" % id)
		return amount
	var remaining: int = amount
	var max_stack: int = item.max_stack if item.stackable else 1

	# 1) Dồn vào các stack cùng loại chưa đầy.
	if item.stackable:
		for i in slot_count:
			if remaining <= 0:
				break
			if slots[i].get("id", &"") == id and slots[i].get("count", 0) < max_stack:
				var space: int = max_stack - slots[i]["count"]
				var moved: int = mini(space, remaining)
				slots[i]["count"] += moved
				remaining -= moved

	# 2) Đổ phần còn lại vào ô trống.
	for i in slot_count:
		if remaining <= 0:
			break
		if is_slot_empty(i):
			var moved: int = mini(max_stack, remaining)
			slots[i] = {"id": id, "count": moved}
			remaining -= moved

	if remaining != amount:
		changed.emit()
	return remaining

## Bỏ item khỏi túi. Trả về số lượng thực sự đã bỏ.
func remove_item(id: StringName, amount: int = 1) -> int:
	var removed: int = 0
	for i in slot_count:
		if removed >= amount:
			break
		if slots[i].get("id", &"") == id:
			var take: int = mini(slots[i]["count"], amount - removed)
			slots[i]["count"] -= take
			removed += take
			if slots[i]["count"] <= 0:
				slots[i] = {}
	if removed > 0:
		changed.emit()
	return removed

## Tổng số lượng của một item trong túi.
func count_of(id: StringName) -> int:
	var total: int = 0
	for slot in slots:
		if slot.get("id", &"") == id:
			total += slot.get("count", 0)
	return total

func has_item(id: StringName, amount: int = 1) -> bool:
	return count_of(id) >= amount

## Xóa toàn bộ (dùng khi New Game).
func clear() -> void:
	for i in slot_count:
		slots[i] = {}
	changed.emit()

# --- Save/Load ---

func to_array() -> Array:
	var out: Array = []
	for slot in slots:
		if slot.is_empty():
			out.append({})
		else:
			out.append({"id": String(slot["id"]), "count": int(slot["count"])})
	return out

func from_array(data: Array) -> void:
	_ensure_slots()
	for i in slot_count:
		if i < data.size() and data[i] is Dictionary and not (data[i] as Dictionary).is_empty():
			var d: Dictionary = data[i]
			slots[i] = {"id": StringName(d.get("id", "")), "count": int(d.get("count", 0))}
		else:
			slots[i] = {}
	changed.emit()
