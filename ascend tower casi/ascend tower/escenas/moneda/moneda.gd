extends Node2D
@export var area_2d: Area2D
@export var reproductor: AudioStreamPlayer2D 


var contenedor_monedas: ContenedorMonedas

func _ready() -> void:
	area_2d.body_entered.connect(_recogida)
	_iniciar_animacion()

func _recogida(_body):
	contenedor_monedas.moneda_recogida()
	reproductor.reparent(get_parent().get_parent().get_parent())
	reproductor.play()
	queue_free()

func _iniciar_animacion():
	# Movimiento arriba y abajo
	var tween_pos: Tween = create_tween()
	tween_pos.set_loops(0)
	tween_pos.tween_property(self, "position:y", position.y - 5, 1.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween_pos.tween_property(self, "position:y", position.y + 5, 1.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	# Escala que pulsa
	var tween_escala: Tween = create_tween()
	tween_escala.set_loops(0)
	tween_escala.tween_property(self, "scale", Vector2(1.15, 1.15), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween_escala.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	# Rotación 360 continua
	var tween_rot: Tween = create_tween()
	tween_rot.set_loops(0)
	tween_rot.tween_property(self, "rotation_degrees", 360.0, 1.0).set_trans(Tween.TRANS_LINEAR)
