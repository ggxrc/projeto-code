extends TextureButton

# Script para o botão de pausa flutuante
# Mostra/esconde o menu de pausa quando clicado

func _ready():
	# Conectar o sinal de pressed ao método _on_pressed
	pressed.connect(_on_pressed)

func _on_pressed():
	# Tocar som de clique
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		audio_manager.play_sfx("button_click")
	
	# Alternar o estado de pausa
	var parent = get_parent()
	while parent != null:
		if parent.has_method("toggle_pause"):
			parent.toggle_pause()
			return
		parent = parent.get_parent()
