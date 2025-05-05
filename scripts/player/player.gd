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

func _ready():
	movement = preload("res://scripts/player/player_movement.gd").new(self)
	shooter = preload("res://scripts/player/player_shooting.gd").new(self)
	health = preload("res://scripts/common/HealthComponent.gd").new(self)

	movement.set_shooting_reference(shooter)
	movement.init()
	shooter.init()
	health.init()
	jump_force = base_jump_force
func _physics_process(delta):
	movement.update(delta)
	shooter.update(delta)

func _unhandled_input(event):
	shooter.handle_input(event)

func _on_player_detection_area_area_entered(area: Area2D):
	if area.is_in_group("EnemyBullet"):
		health.take_damage(1)

func apply_power_up(power_type: String, value: float):
	print("🏷 Este jugador (ID):", self.get_instance_id())

	match power_type:
		"jump_boost":
			jump_force *= value  # ⬅️ Aquí aplicas el multiplicador
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
