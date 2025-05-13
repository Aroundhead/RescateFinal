extends Node2D

@export var enemy_scene: PackedScene
@export var boss_scene: PackedScene
@export var jump_powerup_scene: PackedScene
@export var checkpoint_scene: PackedScene


var player: Node = null
var boss_marker: Node2D = null
var powerup_marker: Node2D = null
var boss_spawned := false

func _ready():
	var song = preload("res://assets/sfx/song2.mp3")
	MusicManager.player.stop()
	MusicManager.player.stream = song
	MusicManager.player.play()
	if player:
		player.last_checkpoint_position = Vector2(100, 100)
		player.has_checkpoint = true
	# Esperar a que todo esté instanciado
	call_deferred("_initialize_nodes")

func _initialize_nodes():
	
		# Esperar hasta que Player exista
	while player == null:
		await get_tree().process_frame
		player = find_child("Player", true, false)

	boss_marker = find_child("BossSpawnMarker", true, false)
	powerup_marker = find_child("FirstPowerUp", true, false)


		
	await get_tree().process_frame
	await get_tree().process_frame

	player = find_child("Player", true, false)
	boss_marker = find_child("BossSpawnMarker", true, false)
	powerup_marker = find_child("FirstPowerUp", true, false)

	# Enemigos
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
	if not boss_spawned and boss_marker and player:
		if abs(player.global_position.x - boss_marker.global_position.x) < 10:
			spawn_boss()

func spawn_boss():
	if boss_scene and boss_marker:
		var boss = boss_scene.instantiate()
		boss.origin_x = boss_marker.global_position.x  # ← asegúrate que esto exista en el boss script
		add_child(boss)
		boss.global_position = boss_marker.global_position
		boss_spawned = true
		print("🧠 Boss instanciado en:", boss.global_position)
