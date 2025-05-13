extends RefCounted
class_name EnemyShooting

var enemy
var is_reloading := false
var shoot_timer := 0.0

func _init(_enemy):
	enemy = _enemy

func init():
	shoot_timer = enemy.shoot_interval

func update(delta):
	if not enemy.player_in_range or is_reloading or not enemy.player_reference:
		return

	shoot_timer -= delta
	if shoot_timer <= 0:
		shoot()

func shoot():
	if enemy.health.is_dead:
		return  # ⛔ Ya murió, no dispares

	is_reloading = true
	shoot_timer = enemy.shoot_interval
	enemy.face_player()

	var bullet = enemy.bullet_scene.instantiate()
	bullet.global_position = enemy.bullet_spawn.global_position
	bullet.set_target_position(enemy.player_reference.global_position)
	bullet.set_source(true)
	bullet.shoot_sound = preload("res://assets/sfx/shoot.wav")  # ✅ asignado antes

	enemy.get_tree().current_scene.add_child(bullet)  # ✅ escena actual

	if bullet.has_node("AnimatedSprite2D"):
		bullet.get_node("AnimatedSprite2D").play("enemyAttack")

	enemy.sprite.play("Attack")

	await enemy.get_tree().create_timer(0.5).timeout

	if enemy.health.is_dead:
		return

	enemy.sprite.play("Reload")
	await enemy.get_tree().create_timer(1.0).timeout

	is_reloading = false


func reset():
	is_reloading = false
	shoot_timer = enemy.shoot_interval
