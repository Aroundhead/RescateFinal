extends Node2D

@export var enemy_scene: PackedScene
@export var boss_scene: PackedScene
@export var jump_powerup_scene: PackedScene
@export var checkpoint_scene: PackedScene

@onready var player = get_node_or_null("Player")
@onready var boss_marker = get_node_or_null("BossSpawnMarker")
@onready var powerup_marker = get_node_or_null("FirstPowerUp")

var boss_spawned := false

func _ready():
	if not player:
		print("❌ Player no encontrado")
	if not boss_marker:
		print("❌ BossSpawnMarker no encontrado")
	if not powerup_marker:
		print("⚠️ FirstPowerUp no encontrado")

	# Enemigos normales
	if enemy_scene:
		for child in get_children():
			if child.name.begins_with("EnemySpawnMarker") and child is Node2D:
				var enemy = enemy_scene.instantiate()
				add_child(enemy)
				enemy.global_position = child.global_position

	# Power-Up
	if jump_powerup_scene and powerup_marker:
		var powerup = jump_powerup_scene.instantiate()
		add_child(powerup)
		powerup.global_position = powerup_marker.global_position
		powerup.power_type = "jump_boost"
		powerup.value = 1.5

	# Checkpoints
	if checkpoint_scene and player:
		for child in get_children():
			if child.name.begins_with("CheckpointMarker") and child is Node2D:
				var checkpoint = checkpoint_scene.instantiate()
				add_child(checkpoint)
				checkpoint.global_position = child.global_position
				checkpoint.connect("checkpoint_reached", Callable(player, "_on_checkpoint_reached"))

func _process(_delta):
	if not boss_spawned and player and boss_marker and abs(player.global_position.x - boss_marker.global_position.x) < 10:
		spawn_boss()

func spawn_boss():
	if boss_scene and boss_marker:
		var boss = boss_scene.instantiate()
		boss.origin_x = boss_marker.global_position.x
		add_child(boss)
		boss.global_position = boss_marker.global_position
		boss_spawned = true
