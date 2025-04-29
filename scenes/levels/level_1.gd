extends Node2D

@onready var enemy_spawn = $EnemySpawnMarker  # Ajusta el path si es necesario
@export var enemy_scene: PackedScene  # Asigna la escena del enemigo en el Inspector

func _ready():
	if enemy_scene:
		var enemy = enemy_scene.instantiate()
		add_child(enemy)
		enemy.global_position = enemy_spawn.global_position
