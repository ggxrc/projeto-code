extends Control

# HUD.gd - Gerencia a interface do usuário durante o gameplay

# Referências para elementos da interface
@onready var interaction_button = $InteractionContainer/InteractionButton
@onready var pause_button = $PauseButton

# Sinais emitidos pelo HUD
signal interaction_requested
signal pause_requested

func _ready():
	# Conectar sinais
	interaction_button.pressed.connect(_on_interaction_button_pressed)
	pause_button.pressed.connect(_on_pause_button_pressed)
	
	# Esconder o botão de interação inicialmente
	hide_interaction_button()

# Mostrar botão de interação com texto personalizado
func show_interaction_button(text: String = "Interagir"):
	interaction_button.text = text
	interaction_button.visible = true

# Esconder botão de interação
func hide_interaction_button():
	interaction_button.visible = false

# Aplicar efeito visual ao botão de interação (destaque)
func highlight_interaction_button(highlight: bool = true):
	var normal_color = Color(1.0, 1.0, 1.0, 1.0)
	var highlight_color = Color(1.0, 1.0, 0.5, 1.0)
	
	if highlight:
		interaction_button.modulate = highlight_color
	else:
		interaction_button.modulate = normal_color

# Callback para clique no botão de interação
func _on_interaction_button_pressed():
	emit_signal("interaction_requested")

# Callback para clique no botão de pausa
func _on_pause_button_pressed():
	emit_signal("pause_requested")
