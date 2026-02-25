extends TileMapLayer

@onready var area_deteccion = $Area2D  # El Area2D que acabas de crear

func _ready():
	# Conecta la señal del Area2D
	if area_deteccion:
		area_deteccion.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Comprueba si lo que entra es el personaje
	if body.name == "personaje":
		print("¡Pincho tocado!")  # Para ver si funciona
		get_tree().reload_current_scene()
