extends CharacterBody2D

@export var speed := 30
@export var gravity := 500
@export var bullet_scene: PackedScene
@export var shoot_interval := 2.0
@export var max_health := 5

@onready var bullet_spawn = $BulletSpawn
@onready var sprite = $AnimatedSprite2D
@onready var detection_area = $detectionArea
@onready var hitbox = $Hitbox
@onready var floor_ray = $FloorRay
@onready var health_bar = $HealthBar

var player_in_range = false
var player_reference: Node2D = null
var patrol_direction := 1
var start_position := Vector2.ZERO

# COMPONENTES
var patrol
var shooter
var health

func _ready():
	patrol = preload("res://scripts/enemies/EnemySoldier/EnemyPatrol.gd").new(self)
	shooter = preload("res://scripts/enemies/EnemySoldier/EnemyShooting.gd").new(self)
	health = preload("res://scripts/common/HealthComponent.gd").new(self)
	start_position = global_position
	patrol.init()
	shooter.init()
	health.init()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	if not shooter.is_reloading and not player_in_range:
		patrol.update(delta)

	shooter.update(delta)
	move_and_slide()

func face_player():
	if player_reference:
		var dir = player_reference.global_position.x < global_position.x
		sprite.flip_h = dir
		bullet_spawn.position.x = abs(bullet_spawn.position.x) * (-1 if dir else 1)
		floor_ray.position.x = abs(floor_ray.position.x) * (-1 if dir else 1)
		
func _on_area_entered(area: Area2D):
	var parent = area.get_parent()
	if parent.is_in_group("player"):
		player_in_range = true
		player_reference = parent

func _on_area_exited(area: Area2D):
	var parent = area.get_parent()
	if parent.is_in_group("player"):
		player_in_range = false
		player_reference = null
		shooter.reset()
		sprite.play("Walk")

		# 🧠 Restaurar orientación del patrullaje
		var dir = patrol_direction == -1
		sprite.flip_h = dir
		bullet_spawn.position.x = abs(bullet_spawn.position.x) * patrol_direction
		floor_ray.position.x = abs(floor_ray.position.x) * patrol_direction


func _on_hitbox_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		health.take_damage(1)
