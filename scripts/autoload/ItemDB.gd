extends Node
## ItemDB - Autoload tra cứu ItemData theo id.
## Nạp toàn bộ .tres trong data/items/ lúc khởi động.

const ITEMS_DIR: String = "res://data/items"

var _items: Dictionary = {}  # StringName -> ItemData

func _ready() -> void:
	_load_all()

func _load_all() -> void:
	var dir: DirAccess = DirAccess.open(ITEMS_DIR)
	if dir == null:
		push_warning("ItemDB: không mở được thư mục %s" % ITEMS_DIR)
		return
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and _is_resource_file(file_name):
			var clean_name: String = file_name.trim_suffix(".remap")
			var path: String = "%s/%s" % [ITEMS_DIR, clean_name]
			var res: Resource = load(path)
			if res is ItemData:
				var item: ItemData = res as ItemData
				if item.id != &"":
					_items[item.id] = item
				else:
					push_warning("ItemDB: item thiếu id: %s" % path)
		file_name = dir.get_next()
	dir.list_dir_end()

func _is_resource_file(file_name: String) -> bool:
	# Trong export, .tres có thể thành .res/.tres.remap.
	return file_name.ends_with(".tres") or file_name.ends_with(".res") \
		or file_name.ends_with(".tres.remap") or file_name.ends_with(".res.remap")

## Lấy ItemData theo id. Trả null nếu không có.
func get_item(id: StringName) -> ItemData:
	return _items.get(id, null)

func has_item(id: StringName) -> bool:
	return _items.has(id)

func all_ids() -> Array:
	return _items.keys()
