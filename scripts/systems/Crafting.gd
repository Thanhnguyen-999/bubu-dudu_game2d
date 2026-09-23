extends RefCounted
class_name Crafting
## Logic chế tạo thuần (không UI). Kiểm tra + thực hiện craft trên PlayerInventory.

## Có đủ nguyên liệu để chế tạo recipe không?
static func can_craft(recipe: RecipeData) -> bool:
	for req in recipe.get_inputs():
		if not PlayerInventory.has_item(req["id"], req["amount"]):
			return false
	return true

## Thực hiện chế tạo. Trả về true nếu thành công (đã trừ liệu + thêm sản phẩm).
static func craft(recipe: RecipeData) -> bool:
	if not can_craft(recipe):
		return false
	for req in recipe.get_inputs():
		PlayerInventory.remove_item(req["id"], req["amount"])
	PlayerInventory.add_item(recipe.output_id, recipe.output_amount)
	return true
