extends Node2D

@export var enemy_scene: PackedScene

func _ready():
	if not enemy_scene:
		return

	for child in get_children():
		if child.name.begins_with("EnemySpawnMarker"):
			var enemy = enemy_scene.instantiate()
			add_child(enemy)
			enemy.global_position = child.global_position
