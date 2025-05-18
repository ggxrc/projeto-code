extends CharacterBody2D

func _physics_process(delta: float) -> void:
	_move()
	
func _move() -> void:
	var _direction: Vector2 = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
