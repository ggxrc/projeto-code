extends CanvasLayer

# Script simplificado para o menu de pausa dentro da cena Gameplay
# Não depende do orquestrador

signal continuar_pressed
signal reiniciar_pressed
signal menu_pressed
signal sair_pressed

func _ready() -> void:
	# Conecta os sinais dos botões
	var continuar_button = $Control/VBoxContainer/ContinuarButton
	var reiniciar_button = $Control/VBoxContainer/ReiniciarButton
	var menu_button = $Control/VBoxContainer/MenuButton
	var sair_button = $Control/VBoxContainer/SairButton
	
	if continuar_button:
		continuar_button.pressed.connect(_on_continuar_pressed)
		
	if reiniciar_button:
		reiniciar_button.pressed.connect(_on_reiniciar_pressed)
	
	if menu_button:
		menu_button.pressed.connect(_on_menu_pressed)
		
	if sair_button:
		sair_button.pressed.connect(_on_sair_pressed)

# Manipuladores de eventos para os botões
func _on_continuar_pressed() -> void:
	# Reproduz som de clique
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		audio_manager.play_sfx("button_click")
	
	# Emite o sinal de continuar
	continuar_pressed.emit()

func _on_reiniciar_pressed() -> void:
	# Reproduz som de clique
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		audio_manager.play_sfx("button_click")
	
	# Emite o sinal de reiniciar
	reiniciar_pressed.emit()

func _on_menu_pressed() -> void:
	# Reproduz som de clique
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		audio_manager.play_sfx("button_click")
	
	# Emite o sinal de menu
	menu_pressed.emit()

func _on_sair_pressed() -> void:
	# Reproduz som de clique
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		audio_manager.play_sfx("button_click")
	
	# Emite o sinal de sair
	sair_pressed.emit()
