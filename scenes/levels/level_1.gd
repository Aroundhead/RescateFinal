extends Node2D

@export var enemy_scene: PackedScene
@export var jump_powerup_scene: PackedScene  # ← Add this export to set your power-up scene in the editor

func _ready():
	if enemy_scene:
		for child in get_children():
			if child.name.begins_with("EnemySpawnMarker"):
				var enemy = enemy_scene.instantiate()
				add_child(enemy)
				enemy.global_position = child.global_position

	# 👉 Power-Up spawn
	var marker = $FirstPowerUp
	if jump_powerup_scene and marker:
		var powerup = jump_powerup_scene.instantiate()
		add_child(powerup)
		powerup.global_position = marker.global_position

		# 👇 Asignar tipo y valor correctamente
		powerup.power_type = "jump_boost"
		powerup.value = 1.5
