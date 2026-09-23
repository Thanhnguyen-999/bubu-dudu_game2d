extends Node2D
## House - map trong nhà: nơi lưu game (giường), cất đồ (rương), chế tạo (bàn).
## Cổng ra dẫn tới Forest (nối logic ở Task 6).

func _ready() -> void:
	# Đặt player vào spawn mặc định nếu vào trực tiếp (không qua SceneManager).
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	var spawn: Node = get_node_or_null("SpawnPoints/Spawn_default")
	if player and spawn and spawn is Node2D:
		player.global_position = (spawn as Node2D).global_position
