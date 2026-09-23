extends Resource
class_name ItemData
## Định nghĩa dữ liệu một loại vật phẩm (data-driven, lưu dạng .tres).
## Inventory tham chiếu ItemData qua id chuỗi để dễ save/load.

enum ItemType {
	MATERIAL,  # nguyên liệu (gỗ, đá, quặng)
	TOOL,      # công cụ (rìu, cuốc)
	WEAPON,    # vũ khí (kiếm, cung)
	CONSUMABLE,# tiêu hao (thức ăn, thuốc)
	MISC,
}

@export var id: StringName = &""          # định danh duy nhất, VD &"wood"
@export var display_name: String = ""      # tên hiển thị, VD "Gỗ"
@export var icon: Texture2D                # icon trong túi (có thể null -> vẽ màu)
@export var icon_color: Color = Color(0.8, 0.8, 0.8)  # màu fallback nếu chưa có icon
@export var type: ItemType = ItemType.MATERIAL
@export var stackable: bool = true
@export var max_stack: int = 99
@export_multiline var description: String = ""

## Damage cho tool/weapon (dùng ở Task 7 khai thác, Task 8 chiến đấu).
@export var power: int = 1
