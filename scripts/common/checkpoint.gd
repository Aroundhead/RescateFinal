extends Area2D

signal checkpoint_reached(position: Vector2)

var activated := false

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area: Area2D):
	if activated:
		return

	if area.is_in_group("player"):  # o algún "PlayerDetector" si es un subnodo
		activated = true
		emit_signal("checkpoint_reached", global_position)
		print("✅ Checkpoint alcanzado con área:", area.name)
