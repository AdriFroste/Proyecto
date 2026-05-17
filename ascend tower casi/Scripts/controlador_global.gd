extends Node
var modo_experto: bool = false
signal muertes_actualizado
var nivel: int
var muertes: int
var checkpoint: Vector2 = Vector2.ZERO
var tiene_checkpoint: bool = false

func sumar_muerte():
	muertes += 1
	muertes_actualizado.emit()
	
	
	
