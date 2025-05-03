extends RefCounted
class_name player_movement

var player
var shooter

func _init(_player):
	player = _player

func set_shooting_reference(_shooter):
	shooter = _shooter

func init():
	player.velocity = Vector2.ZERO

func update(delta):
	var direction = Vector2.ZERO

	if Input.is_action_just_pressed("ui_up") and player.is_on_floor() and not shooter.is_shooting:
		player.velocity.y = player.jump_force

	if not shooter.is_shooting:
		if Input.is_action_pressed("ui_right"):
			direction.x += 1
			player.sprite.flip_h = false
			player.bullet_spawn.position = player.bullet_spawn_offset_right
		elif Input.is_action_pressed("ui_left"):
			direction.x -= 1
			player.sprite.flip_h = true
			player.bullet_spawn.position = player.bullet_spawn_offset_left

	player.velocity.y += player.gravity * delta
	player.velocity.x = direction.x * player.speed
	player.move_and_slide()

	# Animations
	if Input.is_action_pressed("shoot"):
		player.sprite.play("shot")
	elif direction.x != 0:
		player.sprite.play("run")
	else:
		player.sprite.play("Idle")
