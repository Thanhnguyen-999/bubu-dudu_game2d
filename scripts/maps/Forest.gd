extends Node2D
## Forest - map ngoài trời để khám phá: chặt cây, đào khoáng, săn thú (task sau).
## Cổng bên trái dẫn về Nhà.

func _ready() -> void:
	# Nếu vào trực tiếp (không qua SceneManager), đặt player vào spawn mặc định.
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	var spawn: Node = get_node_or_null("SpawnPoints/Spawn_default")
	if player and spawn and spawn is Node2D:
		player.global_position = (spawn as Node2D).global_position
