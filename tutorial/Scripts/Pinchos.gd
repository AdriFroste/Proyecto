extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Espera un momento
	await get_tree().create_timer(0.01).timeout
	
	# Busca al jugador por grupo
	if body.is_in_group("player") or "personaje" in body.name.to_lower():
		get_tree().reload_current_scene()
