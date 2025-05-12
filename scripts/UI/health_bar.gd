extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar = $DamageBar

var health_owner: Node = null  # ✅ Nombre diferente

var health = 0 : set = _set_health

func _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health

	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health

func init_health(_health, _owner = null):
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health
	health_owner = _owner  # ✅ Asignar al nombre nuevo

func _on_timer_timeout() -> void:
	damage_bar.value = health
