extends RefCounted
class_name HealthComponent

var owner
var is_dead := false
var current_health := 0
var max_health := 0

func _init(_owner):
	owner = _owner

func init():
	max_health = owner.max_health
	current_health = max_health

	if owner.has_node("CanvasLayer/HealthBar"):
		owner.get_node("CanvasLayer/HealthBar").init_health(max_health)
	elif owner.has_node("HealthBar"):
		owner.get_node("HealthBar").init_health(max_health)

	if owner.has_node("AnimatedSprite2D"):
		owner.get_node("AnimatedSprite2D").animation_finished.connect(_on_animation_finished)

func take_damage(amount: int):
	if is_dead:
		return

	current_health -= amount

	if owner.has_node("CanvasLayer/HealthBar"):
		owner.get_node("CanvasLayer/HealthBar").health = current_health
	elif owner.has_node("HealthBar"):
		owner.get_node("HealthBar").health = current_health

	if current_health <= 0:
		die()

func die():
	is_dead = true

	if owner.has_node("AnimatedSprite2D"):
		owner.get_node("AnimatedSprite2D").play("die")

	owner.set_physics_process(false)

func _on_animation_finished():
	if not is_dead:
		return

	if owner.has_node("AnimatedSprite2D"):
		var sprite = owner.get_node("AnimatedSprite2D")
		if sprite.animation == "die":
			var timer = owner.get_tree().create_timer(1.5)
			timer.timeout.connect(func():
				if is_instance_valid(owner):
					owner.queue_free()
			)
