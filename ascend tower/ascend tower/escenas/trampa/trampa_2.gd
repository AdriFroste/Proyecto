extends StaticBody2D

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	$GPUParticles2D.emitting = false

func _on_body_entered(body):
	if body.is_in_group("personajes"):
		_temblar()
		await get_tree().create_timer(0.5).timeout
		$Sprite2D.visible = false
		$CollisionShape2D.set_deferred("disabled", true)
		$GPUParticles2D.emitting = true
		await get_tree().create_timer(0.5).timeout
		queue_free()

func _temblar():
	var pos_original = $Sprite2D.position
	var tween = create_tween()
	tween.set_loops(10)
	tween.tween_property($Sprite2D, "position", pos_original + Vector2(1, 0), 0.05)
	tween.tween_property($Sprite2D, "position", pos_original + Vector2(-1, 0), 0.05)
