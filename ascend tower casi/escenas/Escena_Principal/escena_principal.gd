extends Node2D
@export var controlador_partida: ControladorPartida
@export var niveles: Array [PackedScene]
@export var niveles_experto: Array[PackedScene]
var _nivel_actual: int = 1
var _nivel_instanciado: Node
@onready var cortinilla = $CanvasLayer2/ColorRect

func _ready() -> void:
	# 1. Primero decidimos qué lista de niveles usar (Normal o Experto)
	if ControladorGlobal.modo_experto:
		niveles = niveles_experto
	
	# 2. Ajustamos la visibilidad de la cortinilla
	cortinilla.modulate.a = 0
	
	# 3. Combinación de los dos códigos:
	# Si el nivel es mayor a 1, cargamos la partida; si no, creamos el nivel desde cero
	if ControladorGlobal.nivel > 1:
		_cargar_nivel()
	else:
		_crear_nivel(_nivel_actual)

func _crear_nivel(numero_nivel: int):
	_nivel_instanciado = niveles[numero_nivel - 1].instantiate()
	add_child(_nivel_instanciado)
	var hijos := _nivel_instanciado.get_children()
	for i in hijos.size():
		if hijos[i].is_in_group("personajes"):
			hijos[i].personaje_muerto.connect(_reiniciar_nivel)
			break
	ControladorGlobal.nivel = numero_nivel
	controlador_partida.guardar_partida()
	

func _eliminar_nivel():
	_nivel_instanciado.queue_free()

func _reiniciar_nivel():
	_eliminar_nivel()
	_crear_nivel.call_deferred(_nivel_actual)

func siguiente_nivel():
	var tween = create_tween()
	tween.tween_property(cortinilla, "modulate:a", 1.0, 0.5)
	await tween.finished
	_nivel_actual += 1
	_eliminar_nivel()
	ControladorGlobal.tiene_checkpoint = false
	ControladorGlobal.checkpoint = Vector2.ZERO
	_crear_nivel.call_deferred(_nivel_actual)
	await get_tree().process_frame
	var tween2 = create_tween()
	tween2.tween_property(cortinilla, "modulate:a", 0.0, 0.5)

func _cargar_nivel():
	_nivel_actual = ControladorGlobal.nivel
	_crear_nivel.call_deferred(_nivel_actual)
