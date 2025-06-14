extends AudioStreamPlayer

func _on_menu_principal_visibility_changed() -> void:
	if is_playing():
		stop()
	else:
		play()
