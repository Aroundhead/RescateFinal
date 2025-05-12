extends CharacterBody2D

@export var max_health := 5
@export var bullet_scene: PackedScene

@export var shoot_interval := 0.1
@export var speed := 200
@export var gravity := 500
@export var base_jump_force := -300
var jump_force: float

@onready var bullet_spawn = $BulletSpawn
@export var bullet_spawn_offset_right := Vector2(21, -4)
@export var bullet_spawn_offset_left := Vector2(-21, -4)

@onready var sprite = $AnimatedSprite2D
@onready var health_bar = $CanvasLayer/HealthBar

# COMPONENTS
var movement
var shooter
var health

# Checkpoint tracking
var last_checkpoint_position: Vector2 = Vector2.ZERO
var has_checkpoint := false

func _ready():
	print("👤 Player está en grupos:", get_groups())

	movement = preload("res://scripts/player/player_movement.gd").new(self)
	shooter = preload("res://scripts/player/player_shooting.gd").new(self)
	health = preload("res://scripts/common/HealthComponent.gd").new(self)

	health.died.connect(respawn)

	movement.set_shooting_reference(shooter)
	movement.init()
	shooter.init()
	health.init()
	jump_force = base_jump_force

func _physics_process(delta):
	movement.update(delta)
	shooter.update(delta)

	if global_position.y > 725: 
		respawn()

func take_damage(amount: int):
	health.take_damage(amount)

func _on_checkpoint_reached(pos: Vector2):
	last_checkpoint_position = pos
	has_checkpoint = true
	print("📍 Checkpoint asignado al jugador:", pos)

func respawn():
	print("☠️ Jugador cayó, respawneando...")

	if has_checkpoint:
		global_position = last_checkpoint_position
		print("📍 Respawn en último checkpoint:", last_checkpoint_position)
	else:
		global_position = Vector2(-99, 579)  # Posición inicial predeterminada
		print("🔁 Respawn en punto inicial")

func _unhandled_input(event):
	shooter.handle_input(event)

func _on_player_detection_area_area_entered(area: Area2D):
	if area.is_in_group("EnemyBullet"):
		health.take_damage(1)

func apply_power_up(power_type: String, value: float):
	print("🏷 Este jugador (ID):", self.get_instance_id())

	match power_type:
		"jump_boost":
			jump_force *= value
			print("✅ Jump force multiplicado. Nuevo valor:", jump_force)

		"speed_boost":
			speed *= value
			print("🏃‍♂️ Speed boost aplicado. Nuevo valor:", speed)

		"health_restore":
			health.heal(value)
			print("💚 Vida restaurada en", value)

		"weapon_upgrade":
			shooter.upgrade_weapon(value)
			print("🔫 Mejora de arma aplicada")
