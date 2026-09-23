extends CanvasLayer
class_name ChestUI
## UI rương: 2 lưới ô (túi người chơi | rương). Chạm 1 ô để chuyển 1 stack qua bên kia.
## Túi -> Rương (chạm ô túi) ; Rương -> Túi (chạm ô rương).

const SLOT_SCENE: PackedScene = preload("res://scenes/ui/InventorySlotUI.tscn")

@onready var _root: Control = $Root
@onready var _bag_grid: GridContainer = $Root/Panel/VBoxOuter/HBox/BagSide/BagGrid
@onready var _chest_grid: GridContainer = $Root/Panel/VBoxOuter/HBox/ChestSide/ChestGrid

var _bag: Inventory
var _chest: Inventory
var _bag_slots: Array[InventorySlotUI] = []
var _chest_slots: Array[InventorySlotUI] = []
var _is_open: bool = false

func _ready() -> void:
	layer = 22
	_root.visible = false

func open() -> void:
	_bag = PlayerInventory.inventory
	_chest = ChestStorage.inventory
	_build()
	_connect_inventory()
	_refresh()
	_is_open = true
	_root.visible = true

func close() -> void:
	_disconnect_inventory()
	_is_open = false
	_root.visible = false

func _on_close_pressed() -> void:
	close()

func _build() -> void:
	_build_grid(_bag_grid, _bag, _bag_slots, _on_bag_slot_pressed)
	_build_grid(_chest_grid, _chest, _chest_slots, _on_chest_slot_pressed)

func _build_grid(grid: GridContainer, inv: Inventory, store: Array[InventorySlotUI], cb: Callable) -> void:
	for child in grid.get_children():
		child.queue_free()
	store.clear()
	grid.columns = 5
	for i in inv.slot_count:
		var slot: InventorySlotUI = SLOT_SCENE.instantiate()
		slot.index = i
		grid.add_child(slot)
		slot.slot_pressed.connect(cb)
		store.append(slot)

func _connect_inventory() -> void:
	if not _bag.changed.is_connected(_refresh):
		_bag.changed.connect(_refresh)
	if not _chest.changed.is_connected(_refresh):
		_chest.changed.connect(_refresh)

func _disconnect_inventory() -> void:
	if _bag and _bag.changed.is_connected(_refresh):
		_bag.changed.disconnect(_refresh)
	if _chest and _chest.changed.is_connected(_refresh):
		_chest.changed.disconnect(_refresh)

func _refresh() -> void:
	for i in _bag_slots.size():
		_bag_slots[i].set_slot(_bag.slots[i])
	for i in _chest_slots.size():
		_chest_slots[i].set_slot(_chest.slots[i])

## Chạm ô túi -> chuyển cả stack sang rương.
func _on_bag_slot_pressed(index: int) -> void:
	_transfer(_bag, _chest, index)

## Chạm ô rương -> chuyển cả stack về túi.
func _on_chest_slot_pressed(index: int) -> void:
	_transfer(_chest, _bag, index)

func _transfer(src: Inventory, dst: Inventory, index: int) -> void:
	var slot: Dictionary = src.slots[index]
	if slot.is_empty():
		return
	var id: StringName = slot["id"]
	var count: int = slot["count"]
	var leftover: int = dst.add_item(id, count)
	# Chỉ bỏ khỏi nguồn phần đã chuyển thành công.
	var moved: int = count - leftover
	if moved > 0:
		src.remove_item(id, moved)
