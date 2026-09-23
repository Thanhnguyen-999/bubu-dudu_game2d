extends CharacterBody2D
class_name Player
## Player - nhân vật chính side-scrolling.
## Di chuyển ngang + nhảy với gravity. Input được đọc qua PlayerInput để
## touch controls (Task 2) có thể ghi đè mà không sửa logic ở đây.

@export var move_speed: float = 220.0
@export var jump_velocity: float = -430.0
@export var gravity: float = 1100.0
@export var max_fall_speed: float = 900.0

## Hướng đang nhìn (1 = phải, -1 = trái). Dùng cho tấn công/khai thác sau này.
var facing: int = 1

## Danh sách interactable đang trong tầm; nhấn tương tác dùng cái gần nhất.
var _nearby_interactables: Array[Node] = []

## Sát thương tay không (khi chưa có công cụ/vũ khí phù hợp).
@export var base_attack_power: int = 1
## Thời gian bật hitbox mỗi đòn (giây).
@export var attack_active_time: float = 0.12
## Hồi chiêu giữa 2 đòn (giây).
@export var attack_cooldown: float = 0.35
## Bất tử tạm sau khi trúng đòn (giây).
@export var invuln_time: float = 0.7
## Vũ khí tầm xa mặc định (nếu có trong túi -> bắn được).
@export var ranged_weapon: StringName = &"bow"

var _attack_timer: float = 0.0
var _cooldown_timer: float = 0.0
var _invuln_timer: float = 0.0

signal health_changed(current: int, maximum: int)
signal player_died

const PROJECTILE_SCENE: PackedScene = preload("res://scenes/actors/Projectile.tscn")

@onready var sprite: Node2D = $Sprite
@onready var _prompt: Label = $InteractPrompt if has_node("InteractPrompt") else null
@onready var _attack_hitbox: Area2D = $AttackHitbox if has_node("AttackHitbox") else null
@onready var _hitbox_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D if has_node("AttackHitbox/CollisionShape2D") else null

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_horizontal_movement()
	_handle_jump()
	move_and_slide()

func _process(delta: float) -> void:
	_handle_interact()
	_update_prompt()
	_handle_attack(delta)
	_handle_ranged()
	if _invuln_timer > 0.0:
		_invuln_timer -= delta

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = minf(velocity.y, max_fall_speed)

func _handle_horizontal_movement() -> void:
	# Trục ngang: -1..1. Bàn phím trả về giá trị rời rạc, joystick ảo trả analog.
	var direction: float = PlayerInput.get_move_axis()
	velocity.x = direction * move_speed

	if direction > 0.01:
		facing = 1
		_update_facing()
	elif direction < -0.01:
		facing = -1
		_update_facing()

func _handle_jump() -> void:
	if PlayerInput.is_jump_pressed() and is_on_floor():
		velocity.y = jump_velocity

func _update_facing() -> void:
	if sprite:
		sprite.scale.x = absf(sprite.scale.x) * float(facing)
	if _attack_hitbox:
		_attack_hitbox.position.x = absf(_attack_hitbox.position.x) * float(facing)

# --- Chiến đấu / khai thác ---

func _handle_attack(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta
	if _attack_timer > 0.0:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_end_attack()

	if PlayerInput.is_attack_pressed() and _cooldown_timer <= 0.0:
		_start_attack()

func _start_attack() -> void:
	if _attack_hitbox == null or _hitbox_shape == null:
		return
	_cooldown_timer = attack_cooldown
	_attack_timer = attack_active_time
	_hitbox_shape.disabled = false
	# Đợi 1 frame vật lý để Area2D cập nhật overlap rồi mới quét mục tiêu.
	await get_tree().physics_frame
	if _attack_hitbox == null:
		return
	_deal_damage_to_overlaps()

func _end_attack() -> void:
	if _hitbox_shape:
		_hitbox_shape.disabled = true

## Quét các mục tiêu trong hitbox và gây sát thương phù hợp.
func _deal_damage_to_overlaps() -> void:
	for area in _attack_hitbox.get_overlapping_areas():
		if area.has_method("take_hit"):
			var power: int = _compute_power_for(area)
			area.take_hit(power, self)

## Tính lực đánh theo mục tiêu: dùng công cụ tốt nhất phù hợp trong túi.
func _compute_power_for(target: Node) -> int:
	var best: int = base_attack_power
	# Loại tài nguyên mong muốn công cụ nào (nếu target khai báo).
	var preferred_tool: StringName = &""
	if "preferred_tool" in target:
		preferred_tool = target.preferred_tool
	if preferred_tool != &"" and PlayerInventory.has_item(preferred_tool):
		var item: ItemData = ItemDB.get_item(preferred_tool)
		if item:
			best = maxi(best, item.power)
	# Nếu là enemy (không có preferred_tool), dùng vũ khí cận chiến tốt nhất.
	if preferred_tool == &"" and PlayerInventory.has_item(&"sword"):
		var sw: ItemData = ItemDB.get_item(&"sword")
		if sw:
			best = maxi(best, sw.power)
	return best

# --- Tấn công tầm xa ---

func _handle_ranged() -> void:
	if not PlayerInput.is_ranged_pressed():
		return
	# Cần có vũ khí tầm xa trong túi.
	if not PlayerInventory.has_item(ranged_weapon):
		return
	_fire_projectile()

func _fire_projectile() -> void:
	var proj: Node = PROJECTILE_SCENE.instantiate()
	get_parent().add_child(proj)
	var item: ItemData = ItemDB.get_item(ranged_weapon)
	var power: int = item.power if item else 3
	if proj.has_method("setup"):
		proj.setup(global_position + Vector2(facing * 24, -4), facing, power)

# --- Máu người chơi ---

func take_damage(amount: int) -> void:
	if _invuln_timer > 0.0:
		return
	GameState.player_health = maxi(0, GameState.player_health - maxi(0, amount))
	_invuln_timer = invuln_time
	_damage_flash()
	health_changed.emit(GameState.player_health, GameState.player_max_health)
	if GameState.player_health <= 0:
		_die()

func heal(amount: int) -> void:
	GameState.player_health = mini(GameState.player_max_health, GameState.player_health + amount)
	health_changed.emit(GameState.player_health, GameState.player_max_health)

func _damage_flash() -> void:
	if sprite == null:
		return
	var tween: Tween = create_tween()
	sprite.modulate = Color(1.8, 0.5, 0.5)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.25)

func _die() -> void:
	player_died.emit()
	# Hồi sinh đơn giản: về nhà + hồi đầy máu (MVP, tránh màn hình game over phức tạp).
	GameState.player_health = GameState.player_max_health
	health_changed.emit(GameState.player_health, GameState.player_max_health)
	SceneManager.goto_map("House", "from_forest")

# --- Hệ thống tương tác ---

func register_interactable(node: Node) -> void:
	if not _nearby_interactables.has(node):
		_nearby_interactables.append(node)

func unregister_interactable(node: Node) -> void:
	_nearby_interactables.erase(node)

## Interactable gần nhất còn hợp lệ (đã bị free thì bỏ).
func _get_nearest_interactable() -> Node:
	var nearest: Node = null
	var best_dist: float = INF
	var to_remove: Array[Node] = []
	for node in _nearby_interactables:
		if not is_instance_valid(node):
			to_remove.append(node)
			continue
		var d: float = global_position.distance_squared_to((node as Node2D).global_position)
		if d < best_dist:
			best_dist = d
			nearest = node
	for n in to_remove:
		_nearby_interactables.erase(n)
	return nearest

func _handle_interact() -> void:
	if not PlayerInput.is_interact_pressed():
		return
	var target: Node = _get_nearest_interactable()
	if target and target.has_method("interact"):
		target.interact(self)

func _update_prompt() -> void:
	if _prompt == null:
		return
	var target: Node = _get_nearest_interactable()
	if target and "prompt_text" in target:
		_prompt.text = "[ %s ]" % target.prompt_text
		_prompt.visible = true
	else:
		_prompt.visible = false
