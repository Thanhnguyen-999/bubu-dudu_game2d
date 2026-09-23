extends Area2D
class_name Interactable
## Đối tượng tương tác được (giường, rương, bàn chế tạo, cổng...).
## Khi player vào vùng Area2D, đối tượng tự đăng ký với player để hiện prompt.
## Nhấn nút tương tác -> player gọi interact() trên đối tượng gần nhất.
##
## Kế thừa và override _on_interact() để định nghĩa hành vi cụ thể.

## Chữ hiện trên prompt (VD: "Ngủ", "Mở rương", "Chế tạo").
@export var prompt_text: String = "Tương tác"
## Có đang cho phép tương tác không (dùng để khóa cổng chưa mở quest).
@export var enabled: bool = true

func _ready() -> void:
	collision_layer = 32  # layer 6 = interactable
	collision_mask = 2    # phát hiện player (layer 2)
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if not enabled:
		return
	if body.is_in_group("player") and body.has_method("register_interactable"):
		body.register_interactable(self)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("unregister_interactable"):
		body.unregister_interactable(self)

## Gọi bởi player khi nhấn nút tương tác. Không override hàm này;
## override _on_interact() để cài đặt hành vi.
func interact(player: Node) -> void:
	if enabled:
		_on_interact(player)

## Override ở lớp con.
func _on_interact(_player: Node) -> void:
	push_warning("Interactable '%s' chưa cài đặt _on_interact()" % name)
