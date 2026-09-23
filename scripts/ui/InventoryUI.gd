extends CanvasLayer
class_name InventoryUI
## UI túi đồ: lưới ô mở/đóng. Lắng nghe Inventory.changed để vẽ lại.
## Toggle bằng input action "toggle_inventory" hoặc nút cảm ứng.

const SLOT_SCENE: PackedScene = preload("res://scenes/ui/InventorySlotUI.tscn")

@export var columns: int = 5

@onready var _root: Control = $Root
@onready var _grid: GridContainer = $Root/Panel/VBox/Grid
@onready var _title: Label = $Root/Panel/VBox/Title

var _inventory: Inventory
var _slot_uis: Array[InventorySlotUI] = []
var _is_open: bool = false

func _ready() -> void:
	layer = 20
	_root.visible = false
	_bind_inventory(PlayerInventory.inventory)

func _bind_inventory(inv: Inventory) -> void:
	if _inventory and _inventory.changed.is_connected(_refresh):
		_inventory.changed.disconnect(_refresh)
	_inventory = inv
	_build_grid()
	if _inventory:
		_inventory.changed.connect(_refresh)
	_refresh()

func _build_grid() -> void:
	for child in _grid.get_children():
		child.queue_free()
	_slot_uis.clear()
	if _inventory == null:
		return
	_grid.columns = columns
	for i in _inventory.slot_count:
		var slot_ui: InventorySlotUI = SLOT_SCENE.instantiate()
		slot_ui.index = i
		_grid.add_child(slot_ui)
		_slot_uis.append(slot_ui)

func _refresh() -> void:
	if _inventory == null:
		return
	for i in _slot_uis.size():
		if i < _inventory.slots.size():
			_slot_uis[i].set_slot(_inventory.slots[i])

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		toggle()

func toggle() -> void:
	set_open(not _is_open)

func set_open(open: bool) -> void:
	_is_open = open
	_root.visible = open
	if open:
		_refresh()

func _on_close_pressed() -> void:
	set_open(false)
