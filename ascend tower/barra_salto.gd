extends Control

var carga: float = 0.0

func update_carga(valor: float) -> void:
	carga = valor
	queue_redraw()

func _draw() -> void:
	var ancho = 40.0
	var alto = 7.0
	var pos = Vector2(-ancho / 2.0, -alto / 2.0)

	# Fondo oscuro
	draw_rect(Rect2(pos, Vector2(ancho, alto)), Color(0.1, 0.1, 0.1), true)

	# Color: rojo → amarillo → verde
	var color: Color
	if carga < 0.5:
		color = Color.RED.lerp(Color.YELLOW, carga * 2.0)
	else:
		color = Color.YELLOW.lerp(Color.GREEN, (carga - 0.5) * 2.0)

	# Relleno
	var ancho_relleno = (ancho - 4.0) * carga
	if ancho_relleno > 0:
		draw_rect(Rect2(pos + Vector2(2, 2), Vector2(ancho_relleno, alto - 4.0)), color, true)
