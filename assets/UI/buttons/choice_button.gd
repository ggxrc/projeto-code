extends Button

# Customizações visuais
var default_color = Color(1.0, 1.0, 1.0)  # Branco
var hover_color = Color(1.0, 0.8, 0.0)     # Dourado

func _ready():
	# Configurar os sinais de hover
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Configuração inicial
	add_theme_color_override("font_color", default_color)

# Quando o mouse entra no botão
func _on_mouse_entered():
	add_theme_color_override("font_color", hover_color)
	
# Quando o mouse sai do botão
func _on_mouse_exited():
	add_theme_color_override("font_color", default_color)
