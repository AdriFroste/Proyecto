extends Camera2D

var pos_y_fija: float

func _ready():
	pos_y_fija = global_position.y

func _process(delta):
	global_position.y = pos_y_fija
