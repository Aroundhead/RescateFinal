extends RefCounted
class_name player_shooting

var player
var shoot_timer := 0.0
var is_shooting := false

func _init(_player):
	player = _player

func init():
	shoot_timer = 0.0
	is_shooting = false

func update(delta):
	if is_shooting:
		shoot_timer -= delta
		if shoot_timer <= 0:
			shoot()
			shoot_timer = player.shoot_interval

func handle_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_shooting = event.pressed
		if event.pressed:
			shoot_timer = 0

func shoot():
	if player.bullet_scene:
		var mouse_pos = player.get_global_mouse_position()

		if mouse_pos.x > player.global_position.x:
			player.sprite.flip_h = false
			player.bullet_spawn.position = player.bullet_spawn_offset_right
		else:
			player.sprite.flip_h = true
			player.bullet_spawn.position = player.bullet_spawn_offset_left

		var bullet = player.bullet_scene.instantiate()
		bullet.global_position = player.bullet_spawn.global_position
		bullet.set_target_position(mouse_pos)
		bullet.set_source(false)
		bullet.shoot_sound = preload("res://assets/sfx/shoot.wav")  # ✅ aquí antes del add_child

		player.get_tree().current_scene.add_child(bullet)  
