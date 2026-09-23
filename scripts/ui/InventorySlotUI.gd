extends Panel
class_name InventorySlotUI
## Một ô trong lưới túi đồ. Hiển thị icon (hoặc màu fallback) + số lượng.

signal slot_pressed(index: int)

var index: int = -1

@onready var _icon: TextureRect = $Icon
@onready var _color: ColorRect = $ColorBox
@onready var _count: Label = $Count
@onready var _button: Button = $Button

func _ready() -> void:
	_button.pressed.connect(func() -> void: slot_pressed.emit(index))

## Cập nhật hiển thị theo dữ liệu ô ({} hoặc {id, count}).
func set_slot(slot: Dictionary) -> void:
	if slot.is_empty():
		_icon.visible = false
		_color.visible = false
		_count.text = ""
		return
	var item: ItemData = ItemDB.get_item(slot.get("id", &""))
	if item == null:
		_icon.visible = false
		_color.visible = false
		_count.text = "?"
		return
	if item.icon != null:
		_icon.texture = item.icon
		_icon.visible = true
		_color.visible = false
	else:
		_color.color = item.icon_color
		_color.visible = true
		_icon.visible = false
	var c: int = int(slot.get("count", 0))
	_count.text = str(c) if c > 1 else ""
