extends Panel

@export var personaje: Node2D
@export var tiempo_limite: float = 11  # Cambiado de 180 a 10
@export var menu_muerte_path: String = "res://tutorial/escenas/menu muerte.tscn"

@onready var label = $Label

var tiempo_restante: float

func _ready():
	tiempo_restante = tiempo_limite
	
	if label == null:
		print("ERROR: No se encontró el Label")

func _process(delta):
	tiempo_restante -= delta
	
	if tiempo_restante <= 0:
		get_tree().change_scene_to_file("res://escenas/menu muerte.tscn")
	
	
	if label:
		var minutos = floor(tiempo_restante / 60)
		var segundos = int(tiempo_restante) % 60
		label.text = "%02d:%02d" % [minutos, segundos]
