extends Node2D
@export var Enemy: PackedScene

func _ready():
	if not Enemy:
		return

	var enemy_container = get_parent()  # ← Level2

	for child in get_children():
		if child.name.begins_with("EnemySpawnMarker"):
			var enemy = Enemy.instantiate()
			enemy_container.call_deferred("add_child", enemy)  # ✅ Esto previene el error
			enemy.global_position = child.global_position
