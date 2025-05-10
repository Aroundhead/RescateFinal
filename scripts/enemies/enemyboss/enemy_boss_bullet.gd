extends Area2D

@export var speed := 250
@export var explosion_scene: PackedScene  # Shader explosion opcional
var velocity := Vector2.DOWN * 250  # Valor por defecto, puede ser sobrescrito por el boss

func _ready():
	print("🚀 Bala activa:", self.name, "en", global_position)
	connect("area_entered", _on_area_entered)
	connect("body_entered", _on_body_entered)

func _process(delta):
	position += velocity * delta

func _on_area_entered(area):
	if area.is_in_group("player") or area.is_in_group("Tile") or area.is_in_group("Solid"):
		_explode(area)

func _on_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("Tile") or body.is_in_group("Solid"):
		_explode(body)

func _explode(target):
	if target.is_in_group("player") and "health" in target:
		target.health.take_damage(1)

	if explosion_scene:
		var fx: Node2D = explosion_scene.instantiate()
		fx.global_position = global_position
		get_tree().current_scene.add_child(fx)

	queue_free()
