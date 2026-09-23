extends Resource
class_name RecipeData
## Công thức chế tạo (data-driven, .tres). Nguyên liệu -> sản phẩm.
## Nguyên liệu lưu dạng Dictionary {id(String): amount(int)} để .tres serialize gọn, an toàn.

@export var recipe_id: StringName = &""
## Nguyên liệu: {"wood": 3, "stone": 2}
@export var inputs: Dictionary = {}
## id sản phẩm.
@export var output_id: StringName = &""
@export var output_amount: int = 1

## Trả về danh sách cặp (id: StringName, amount: int) nguyên liệu.
func get_inputs() -> Array:
	var out: Array = []
	for key in inputs.keys():
		out.append({"id": StringName(key), "amount": int(inputs[key])})
	return out
