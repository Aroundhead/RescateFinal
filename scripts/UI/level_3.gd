extends Node2D

@export var enemy_scene: PackedScene
@export var boss_scene: PackedScene
@export var jump_powerup_scene: PackedScene
@export var checkpoint_scene: PackedScene

@onready var player := $Player
@onready var boss_marker := $BossSpawnMarker

var boss_spawned := false

func _ready():
	# Instanciar enemigos normales
	if enemy_scene:
		for child in get_children():
			if child.name.begins_with("EnemySpawnMarker"):
				var enemy = enemy_scene.instantiate()
				add_child(enemy)
				enemy.global_position = child.global_position

	# Instanciar Power-Up
	# Instanciar todos los Power-Ups llamados "FirstPowerUp*"
	if jump_powerup_scene:
		for child in get_children():
			if child.name.begins_with("FirstPowerUp"):
				var powerup = jump_powerup_scene.instantiate()
				add_child(powerup)
				powerup.global_position = child.global_position
				powerup.power_type = "jump_boost"
				powerup.value = 1.5

	# Instanciar checkpoints
	if checkpoint_scene:
		for child in get_children():
			if child.name.begins_with("CheckpointMarker"):
				var checkpoint = checkpoint_scene.instantiate()
				add_child(checkpoint)
				checkpoint.global_position = child.global_position
				checkpoint.connect("checkpoint_reached", Callable(player, "_on_checkpoint_reached"))

func _process(_delta):
	# Activar boss cuando el jugador se acerca
	if not boss_spawned and abs(player.global_position.x - boss_marker.global_position.x) < 10:
		spawn_boss()

func spawn_boss():
	if boss_scene:
		var boss = boss_scene.instantiate()
		add_child(boss)
		boss.global_position = boss_marker.global_position
		if "origin_x" in boss:
			boss.origin_x = boss_marker.global_position.x
		boss_spawned = true
