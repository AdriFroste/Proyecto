extends Camera2D

var pos_x_fija: float

func _ready():
	pos_x_fija = global_position.x

func _process(delta):
	global_position.x = pos_x_fija
