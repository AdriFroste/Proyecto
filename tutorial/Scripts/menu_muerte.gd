extends Control



func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://nivel_1.tscn")




func _on_button_2_pressed() -> void:
	get_tree().quit()
