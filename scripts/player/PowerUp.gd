extends Area2D

@export_enum("jump_boost", "speed_boost", "health_restore", "weapon_upgrade") var power_type: String
@export var value: float = 1.5  # multiplicador o cantidad
@onready var icon = $Sprite2D

# Diccionario con las texturas de cada tipo
var powerup_textures = {
	"jump_boost": preload("res://assets/img/foreground/Jump_Pwp.png"),
	"health_restore": preload("res://assets/img/foreground/Health_PWp.png"),
	"speed_boost": preload("res://assets/img/foreground/str_pwp.png"),
	"weapon_upgrade": preload("res://assets/img/foreground/str_pwp.png")
}

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))

	# Asignar sprite dinámicamente
	if powerup_textures.has(power_type):
		icon.texture = powerup_textures[power_type]
	else:
		print("⚠️ No hay sprite definido para el tipo:", power_type)

	print("🧪 PowerUp READY → tipo:", power_type, ", valor:", value)

func _process(delta):
	icon.material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
	
func _on_area_entered(area):
	print("🚀 Área tocada:", area.name)

	var player = area.get_parent()

	if player.is_in_group("player"):
		print("✅ El nodo está en el grupo 'player'")
		
		if player.has_method("apply_power_up"):
			player.apply_power_up(power_type, value)
			print("⚡ Aplicado:", power_type, "con valor:", value)
		else:
			print("❌ El nodo no tiene 'apply_power_up()'")

		queue_free()
	else:
		print("❌ El nodo no está en el grupo 'player'")
