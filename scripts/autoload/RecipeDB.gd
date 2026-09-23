extends Node
## RecipeDB - Autoload nạp toàn bộ công thức chế tạo trong data/recipes/.

const RECIPES_DIR: String = "res://data/recipes"

var _recipes: Array[RecipeData] = []

func _ready() -> void:
	_load_all()

func _load_all() -> void:
	var dir: DirAccess = DirAccess.open(RECIPES_DIR)
	if dir == null:
		push_warning("RecipeDB: không mở được %s" % RECIPES_DIR)
		return
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and _is_res(file_name):
			var clean: String = file_name.trim_suffix(".remap")
			var res: Resource = load("%s/%s" % [RECIPES_DIR, clean])
			if res is RecipeData:
				_recipes.append(res as RecipeData)
		file_name = dir.get_next()
	dir.list_dir_end()

func _is_res(file_name: String) -> bool:
	return file_name.ends_with(".tres") or file_name.ends_with(".res") \
		or file_name.ends_with(".tres.remap") or file_name.ends_with(".res.remap")

func all_recipes() -> Array[RecipeData]:
	return _recipes
