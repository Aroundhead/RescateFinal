# EnemyPatrol.gd
extends RefCounted
class_name EnemyPatrol

var enemy

func _init(_enemy):
	enemy = _enemy

func init():
	pass

func update(delta):
	# ❌ No patrullar si ve al jugador o si está recargando
	if enemy.player_in_range or enemy.shooter.is_reloading:
		return

	enemy.velocity.x = enemy.patrol_direction * enemy.speed
	enemy.sprite.play("Walk")
	var turned = false
	if enemy.is_on_floor() and not enemy.floor_ray.is_colliding():
		enemy.patrol_direction *= -1
		turned = true

	if turned:
		enemy.sprite.flip_h = enemy.patrol_direction == -1
		enemy.floor_ray.position.x = abs(enemy.floor_ray.position.x) * enemy.patrol_direction
		enemy.bullet_spawn.position.x = abs(enemy.bullet_spawn.position.x) * enemy.patrol_direction
		enemy.velocity.x = enemy.patrol_direction * enemy.speed
