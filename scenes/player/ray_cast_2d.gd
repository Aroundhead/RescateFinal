extends RayCast2D

signal target_detected(collider: Node2D)

@export var target_group: String = "player"

func _physics_process(_delta):
	if is_colliding():
		var hit = get_collider()
		if hit and hit.is_in_group(target_group):
			emit_signal("target_detected", hit)
