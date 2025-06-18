extends Node2D

@onready var dialogue_box = $DialogueBoxUI

var dialogue_lines = [
	"Olá! Esta é uma caixa de diálogo estilizada com imagem.",
	"Você pode personalizar a aparência dela facilmente.",
	"Experimente mudar a textura de fundo, cor do texto e tamanho da fonte."
]

var current_line_index = 0

func _ready():
	# Configurar estilo inicial (opcional)
	dialogue_box.set_dialogue_style(
		"", # Usando a textura padrão
		Color(0.9, 0.9, 1.0), # Azul claro para o texto
		32, # Tamanho da fonte
		Color(1.0, 1.0, 1.0, 1.0) # Cor e opacidade do fundo
	)
	
	# Conectar sinal de fim da linha
	dialogue_box.dialogue_line_finished.connect(_on_dialogue_line_finished)
	
	# Mostrar a primeira linha
	if dialogue_lines.size() > 0:
		dialogue_box.show_line(dialogue_lines[0])

func _input(event):
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		advance_dialogue()

func advance_dialogue():
	if dialogue_box.is_typewriting():
		# Se estiver digitando, acelerar para mostrar todo o texto
		dialogue_box.advance_or_skip_typewriter()
	else:
		# Se já mostrou toda a linha atual, avance para a próxima
		current_line_index += 1
		if current_line_index < dialogue_lines.size():
			dialogue_box.show_line(dialogue_lines[current_line_index])
		else:
			# Fim do diálogo
			dialogue_box.hide_box()
			current_line_index = 0
			# Você pode adicionar aqui uma ação para quando o diálogo terminar

func _on_dialogue_line_finished():
	# Esta função é chamada quando uma linha de diálogo termina de ser digitada
	pass
