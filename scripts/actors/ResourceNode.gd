extends Area2D
class_name ResourceNode
## Điểm tài nguyên khai thác (cây, đá, quặng). Player đánh vào -> giảm HP.
## Khi HP cạn: rơi item vào túi, ẩn đi, hồi sinh sau respawn_time.
##
## Nằm ở layer 7 (resource_node, value 64) để hitbox player (mask có 64) quét được.

signal harvested(node: ResourceNode)  # phát khi khai thác xong (Quest lắng nghe - Task 10)

## Định danh ổn định để save trạng thái đã khai thác (Task 13).
## Nếu để trống, sẽ tự dùng tên node.
@export var node_id: String = ""

@export var drop_item: StringName = &"wood"
@export var drop_amount: int = 1
@export var max_hp: int = 3
## Công cụ phù hợp (rìu cho cây, cuốc cho đá) - tăng lực đánh của player.
@export var preferred_tool: StringName = &"axe"
@export var respawn_time: float = 8.0

var _hp: int = 0
var _depleted: bool = false

@onready var _visual: CanvasItem = $Visual if has_node("Visual") else null
@onready var _collision: CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else null

func _ready() -> void:
	collision_layer = 64  # layer 7 = resource_node
	collision_mask = 0
	monitorable = true
	if node_id == "":
		node_id = name
	_hp = max_hp
	# Khôi phục trạng thái đã khai thác từ save (nếu có) sau 1 frame để chắc chắn
	# scene đã sẵn sàng.
	call_deferred("_restore_from_state")

func _restore_from_state() -> void:
	var map_key: String = GameState.current_map
	var map_state: Dictionary = GameState.harvested_resources.get(map_key, {})
	if map_state.get(node_id, false):
		restore_state(true)

## Trả về id duy nhất trong phạm vi map (dùng cho save).
func get_unique_id() -> String:
	return node_id

## Ghi trạng thái depleted vào GameState theo map hiện tại.
func _record_state(depleted: bool) -> void:
	var map_key: String = GameState.current_map
	if not GameState.harvested_resources.has(map_key):
		GameState.harvested_resources[map_key] = {}
	if depleted:
		GameState.harvested_resources[map_key][node_id] = true
	else:
		GameState.harvested_resources[map_key].erase(node_id)

## Gọi bởi hitbox của player. power = lực đánh (tool tốt hơn -> nhanh hơn).
func take_hit(power: int, _source: Node = null) -> void:
	if _depleted:
		return
	_hp -= maxi(1, power)
	_flash()
	if _hp <= 0:
		_deplete()

func _flash() -> void:
	if _visual == null:
		return
	var tween: Tween = create_tween()
	_visual.modulate = Color(1.5, 1.5, 1.5)
	tween.tween_property(_visual, "modulate", Color.WHITE, 0.15)

func _deplete() -> void:
	_depleted = true
	# Rơi item vào túi người chơi.
	if drop_item != &"" and drop_amount > 0:
		PlayerInventory.add_item(drop_item, drop_amount)
	harvested.emit(self)
	_record_state(true)
	_set_visible_state(false)
	# Hồi sinh sau timer.
	var t: SceneTreeTimer = get_tree().create_timer(respawn_time)
	t.timeout.connect(_respawn)

func _respawn() -> void:
	_hp = max_hp
	_depleted = false
	_record_state(false)
	_set_visible_state(true)

func _set_visible_state(active: bool) -> void:
	if _visual:
		_visual.visible = active
	if _collision:
		_collision.set_deferred("disabled", not active)
	monitorable = active

# --- Save/Load (Task 13) ---
func is_depleted() -> bool:
	return _depleted

## Khôi phục trạng thái depleted khi load. Nếu đang depleted, đặt lại timer hồi sinh.
func restore_state(depleted: bool) -> void:
	if depleted:
		_depleted = true
		_hp = 0
		_set_visible_state(false)
		var t: SceneTreeTimer = get_tree().create_timer(respawn_time)
		t.timeout.connect(_respawn)
	else:
		_respawn()
