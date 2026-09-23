extends CharacterBody2D
class_name Enemy
## Thú/quái đơn giản với AI: PATROL (đi qua lại) -> CHASE (đuổi player khi thấy)
## -> ATTACK (gây sát thương khi lại gần). Có máu, rơi item khi chết.
##
## Nằm ở layer 3 (enemy, value 4). Hurtbox (Area2D layer 5 = 16) để hitbox player quét trúng.

enum State { PATROL, CHASE, ATTACK, DEAD }

@export var move_speed: float = 70.0
@export var chase_speed: float = 130.0
@export var gravity: float = 1100.0
@export var detect_range: float = 260.0
@export var attack_range: float = 46.0
@export var attack_damage: int = 8
@export var attack_interval: float = 1.0
@export var patrol_distance: float = 140.0

## Item rơi khi chết.
@export var drop_item: StringName = &"fiber"
@export var drop_amount: int = 1

var _state: State = State.PATROL
var _facing: int = -1
var _origin_x: float = 0.0
var _attack_cd: float = 0.0

@onready var _health: HealthComponent = $HealthComponent
@onready var _sprite: Node2D = $Sprite if has_node("Sprite") else null
@onready var _hp_bar: ProgressBar = $HpBar if has_node("HpBar") else null

func _ready() -> void:
	collision_layer = 4   # layer 3 = enemy
	collision_mask = 1    # va chạm world
	_origin_x = global_position.x
	_health.died.connect(_on_died)
	_health.health_changed.connect(_on_health_changed)
	if _hp_bar:
		_hp_bar.max_value = _health.max_health
		_hp_bar.value = _health.current_health

func _on_health_changed(current: int, maximum: int) -> void:
	if _hp_bar:
		_hp_bar.max_value = maximum
		_hp_bar.value = current

func _physics_process(delta: float) -> void:
	if _state == State.DEAD:
		return
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0

	if _attack_cd > 0.0:
		_attack_cd -= delta

	var player: Node2D = _get_player()
	_update_state(player)
	_act(player)
	move_and_slide()
	_update_sprite_facing()

func _get_player() -> Node2D:
	return get_tree().get_first_node_in_group("player") as Node2D

func _update_state(player: Node2D) -> void:
	if player == null:
		_state = State.PATROL
		return
	var dist: float = absf(player.global_position.x - global_position.x)
	var vertical_ok: bool = absf(player.global_position.y - global_position.y) < 120.0
	if dist <= attack_range and vertical_ok:
		_state = State.ATTACK
	elif dist <= detect_range and vertical_ok:
		_state = State.CHASE
	else:
		_state = State.PATROL

func _act(player: Node2D) -> void:
	match _state:
		State.PATROL:
			_patrol()
		State.CHASE:
			_chase(player)
		State.ATTACK:
			_attack(player)

func _patrol() -> void:
	velocity.x = _facing * move_speed
	# Đổi hướng khi đi quá xa điểm gốc.
	if global_position.x > _origin_x + patrol_distance:
		_facing = -1
	elif global_position.x < _origin_x - patrol_distance:
		_facing = 1

func _chase(player: Node2D) -> void:
	_facing = 1 if player.global_position.x > global_position.x else -1
	velocity.x = _facing * chase_speed

func _attack(player: Node2D) -> void:
	velocity.x = 0.0
	_facing = 1 if player.global_position.x > global_position.x else -1
	if _attack_cd <= 0.0:
		_attack_cd = attack_interval
		if player.has_method("take_damage"):
			player.take_damage(attack_damage)

func _update_sprite_facing() -> void:
	if _sprite:
		_sprite.scale.x = 1.0 * float(_facing)

# --- Nhận sát thương (interface chung với ResourceNode) ---
## Gọi bởi hitbox player hoặc projectile.
func take_hit(power: int, _source: Node = null) -> void:
	if _state == State.DEAD:
		return
	_health.take_damage(power)
	_flash()

func _flash() -> void:
	if _sprite == null:
		return
	var tween: Tween = create_tween()
	_sprite.modulate = Color(1.6, 0.6, 0.6)
	tween.tween_property(_sprite, "modulate", Color.WHITE, 0.15)

func _on_died() -> void:
	_state = State.DEAD
	if drop_item != &"" and drop_amount > 0:
		PlayerInventory.add_item(drop_item, drop_amount)
	QuestManager.report_kill()
	# Hiệu ứng biến mất rồi free.
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.tween_callback(queue_free)
