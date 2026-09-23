extends Node2D
## Beach - map stub chứng minh cơ chế mở khóa qua quest.
## Có thể mở rộng thành map khám phá đầy đủ sau.

func _ready() -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	var spawn: Node = get_node_or_null("SpawnPoints/Spawn_default")
	if player and spawn and spawn is Node2D:
		player.global_position = (spawn as Node2D).global_position
