extends Camera2D

func _on_prologue_visibility_changed() -> void:
	if is_visible():
		set_enabled(true)
	else:
		set_enabled(false)
