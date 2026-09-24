extends Node2D
## Rừng - khu khám phá: chặt cây, đào khoáng, săn thú, làm nhiệm vụ.
## Cổng trái quay về Phố Cổ Hoa Lư.

func _ready() -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	var spawn: Node = get_node_or_null("SpawnPoints/Spawn_default")
	if player and spawn and spawn is Node2D:
		player.global_position = (spawn as Node2D).global_position
