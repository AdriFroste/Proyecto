extends Control

func _on_play_pressed() -> void:
	ControladorGlobal.modo_experto = false
	get_tree().change_scene_to_file("res://escenas/Escena_Principal/escena_principal.tscn")

func _on_experto_pressed() -> void:
	ControladorGlobal.modo_experto = true
	get_tree().change_scene_to_file("res://escenas/Escena_Principal/escena_principal.tscn")

func _on_options_pressed() -> void:
	pass

func _on_quit_pressed():
	get_tree().quit()
