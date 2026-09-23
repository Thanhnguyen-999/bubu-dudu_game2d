extends CanvasLayer
## SceneManager - Autoload điều hướng scene trung tâm.
## - Fade out -> đổi scene -> fade in (màn hình loading mượt).
## - goto_scene(path): đổi scene đơn giản (splash, menu, cutscene...).
## - goto_map(map_key, spawn): đổi map gameplay + đặt spawn point (dùng từ Task 6).
##
## Là CanvasLayer để lớp fade luôn phủ trên mọi thứ.

signal scene_changed(new_scene: Node)

## Bảng map key -> đường dẫn scene. Bổ sung dần khi thêm map.
const MAP_PATHS: Dictionary = {
	"House": "res://scenes/maps/House.tscn",
	"Forest": "res://scenes/maps/Forest.tscn",
	"Beach": "res://scenes/maps/Beach.tscn",
}

@export var fade_duration: float = 0.35

var _fade_rect: ColorRect
var _is_transitioning: bool = false

func _ready() -> void:
	layer = 100  # phủ trên UI gameplay (TouchControls ở layer 10)
	_build_fade_layer()

func _build_fade_layer() -> void:
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.anchor_right = 1.0
	_fade_rect.anchor_bottom = 1.0
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade_rect)

## Đổi sang một scene bất kỳ theo đường dẫn res://.
func goto_scene(path: String) -> void:
	if _is_transitioning:
		return
	_transition_to(path, "")

## Đổi sang map gameplay theo key, ghi lại vào GameState, kèm spawn point.
func goto_map(map_key: String, spawn: String = "default") -> void:
	if _is_transitioning:
		return
	if not MAP_PATHS.has(map_key):
		push_error("SceneManager: map key không tồn tại: %s" % map_key)
		return
	GameState.current_map = map_key
	GameState.player_spawn_point = spawn
	_transition_to(MAP_PATHS[map_key], spawn)

func _transition_to(path: String, spawn: String) -> void:
	_is_transitioning = true
	await _fade(1.0)  # tối màn hình

	var tree: SceneTree = get_tree()
	var result: int = tree.change_scene_to_file(path)
	if result != OK:
		push_error("SceneManager: không load được scene: %s" % path)
		_is_transitioning = false
		await _fade(0.0)
		return

	# Đợi scene mới sẵn sàng rồi đặt spawn point.
	await tree.process_frame
	await tree.process_frame
	var new_scene: Node = tree.current_scene
	if new_scene and spawn != "":
		_place_player_at_spawn(new_scene, spawn)
	scene_changed.emit(new_scene)

	await _fade(0.0)  # sáng lại
	_is_transitioning = false

## Đặt player vào Marker2D có tên trùng spawn (nếu map có nhóm spawn points).
func _place_player_at_spawn(scene: Node, spawn: String) -> void:
	var player: Node = scene.get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var spawn_node: Node = _find_spawn(scene, spawn)
	if spawn_node and spawn_node is Node2D and player is Node2D:
		(player as Node2D).global_position = (spawn_node as Node2D).global_position

func _find_spawn(root: Node, spawn: String) -> Node:
	# Tìm node tên "Spawn_<spawn>" trong nhóm "spawn_points".
	for node in root.get_tree().get_nodes_in_group("spawn_points"):
		if node.name == "Spawn_%s" % spawn or node.name == spawn:
			return node
	return null

## Tween alpha của lớp fade tới giá trị đích. Trả về khi xong.
func _fade(target_alpha: float) -> void:
	if _fade_rect == null:
		return
	var tween: Tween = create_tween()
	tween.tween_property(_fade_rect, "color:a", target_alpha, fade_duration)
	await tween.finished
