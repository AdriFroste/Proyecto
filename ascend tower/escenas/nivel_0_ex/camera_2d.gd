extends Camera2D

@export var personaje: CharacterBody2D
@export var activar_en_x: float = -866.0
@export var parar_en_x: float = 489.0
@export var shader_rect: ColorRect
@export var inicio_fade_y: float = 0.0
@export var fin_fade_y: float = -200.0

var siguiendo: bool = false
var pos_y_fija: float

func _ready():
	pos_y_fija = global_position.y

func _process(delta):
	if shader_rect:
		var t = inverse_lerp(inicio_fade_y, fin_fade_y, personaje.global_position.y)
		shader_rect.modulate.a = clamp(1.0 - t, 0.0, 1.0)

	if not siguiendo:
		global_position.y = pos_y_fija
		if personaje.global_position.x >= activar_en_x:
			siguiendo = true
	else:
		if personaje.global_position.x >= parar_en_x:
			global_position.x = parar_en_x
		else:
			global_position = personaje.global_position
