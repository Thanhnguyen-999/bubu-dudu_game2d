extends CanvasLayer
class_name CraftingUI
## UI chế tạo: liệt kê công thức, hiện nguyên liệu, nút Chế tạo bật khi đủ liệu.

@onready var _root: Control = $Root
@onready var _list: VBoxContainer = $Root/Panel/VBox/Scroll/List

var _rows: Array = []  # [{recipe, button, req_label}]
var _is_open: bool = false

func _ready() -> void:
	layer = 22
	_root.visible = false

func open() -> void:
	_build_rows()
	if not PlayerInventory.inventory.changed.is_connected(_refresh_availability):
		PlayerInventory.inventory.changed.connect(_refresh_availability)
	_refresh_availability()
	_is_open = true
	_root.visible = true

func close() -> void:
	if PlayerInventory.inventory.changed.is_connected(_refresh_availability):
		PlayerInventory.inventory.changed.disconnect(_refresh_availability)
	_is_open = false
	_root.visible = false

func _on_close_pressed() -> void:
	close()

func _build_rows() -> void:
	for child in _list.get_children():
		child.queue_free()
	_rows.clear()

	for recipe in RecipeDB.all_recipes():
		var row: PanelContainer = PanelContainer.new()
		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 16)
		row.add_child(hbox)

		var info: VBoxContainer = VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var name_label: Label = Label.new()
		var out_item: ItemData = ItemDB.get_item(recipe.output_id)
		name_label.text = "%s x%d" % [out_item.display_name if out_item else String(recipe.output_id), recipe.output_amount]
		name_label.add_theme_font_size_override("font_size", 24)
		var req_label: Label = Label.new()
		req_label.text = _requirement_text(recipe)
		info.add_child(name_label)
		info.add_child(req_label)
		hbox.add_child(info)

		var btn: Button = Button.new()
		btn.text = "Chế tạo"
		btn.custom_minimum_size = Vector2(160, 56)
		btn.add_theme_font_size_override("font_size", 22)
		btn.pressed.connect(_on_craft_pressed.bind(recipe))
		hbox.add_child(btn)

		_list.add_child(row)
		_rows.append({"recipe": recipe, "button": btn, "req_label": req_label})

func _requirement_text(recipe: RecipeData) -> String:
	var parts: Array = []
	for req in recipe.get_inputs():
		var item: ItemData = ItemDB.get_item(req["id"])
		var nm: String = item.display_name if item else String(req["id"])
		parts.append("%s x%d" % [nm, req["amount"]])
	return "Cần: " + ", ".join(parts)

func _on_craft_pressed(recipe: RecipeData) -> void:
	Crafting.craft(recipe)
	_refresh_availability()

## Bật/tắt nút craft theo nguyên liệu hiện có.
func _refresh_availability() -> void:
	for row in _rows:
		var can: bool = Crafting.can_craft(row["recipe"])
		row["button"].disabled = not can
