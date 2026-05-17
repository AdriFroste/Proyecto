extends Area2D

func _ready():
	$AnimatedSprite2D.play("default")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("personajes"):
		body._on_area_2d_body_entered(self)
