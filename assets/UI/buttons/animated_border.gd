extends Node2D
func _ready():
	var w = get_parent().size.x
	var h = get_parent().size.y

	$TopLeft.position = Vector2(0, 0)
	$TopRight.position = Vector2(w, 0)
	$TopRight.flip_h = true

	$BottomLeft.position = Vector2(0, h)
	$BottomLeft.flip_v = true

	$BottomRight.position = Vector2(w, h)
	$BottomRight.flip_h = true
	$BottomRight.flip_v = true

	# Iniciar a animação
	$AnimationPlayer.play("animar_bordas")
