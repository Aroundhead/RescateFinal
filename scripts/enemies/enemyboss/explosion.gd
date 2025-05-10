extends Node2D

@onready var fx: ShaderMaterial = $FX.material
var timer := 0.0
const FADE_TIME := 0.5

func _process(delta):
	timer += delta
	fx.set_shader_parameter("time", timer)

	if timer >= FADE_TIME:
		queue_free()
