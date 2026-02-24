extends Panel  # O extends Control si tu nodo raíz es un Control

@export var personaje: Node2D
@export var tiempo_limite: float = 180

@onready var label = $Label  # Busca el Label que está DENTRO del Panel

var tiempo_restante: float

func _ready():
	tiempo_restante = tiempo_limite
	
	# Verificación para evitar el error
	if label == null:
		print("ERROR: No se encontró el Label. Revisa que el nodo Label esté dentro del Panel y se llame exactamente 'Label'")

func _process(delta):
	tiempo_restante -= delta
	
	if tiempo_restante <= 0:
		tiempo_restante = 0
		if personaje:
			personaje.queue_free()
		set_process(false)
	
	# Solo actualizar si el label existe
	if label:
		var minutos = floor(tiempo_restante / 60)
		var segundos = int(tiempo_restante) % 60
		label.text = "%02d:%02d" % [minutos, segundos]
