extends TextureRect

# Referências aos gerenciadores
var state_manager
var audio_manager

func _ready():
	# Verificar se já existem conexões para os botões
	var iniciar_btn = $VBoxContainer/Iniciar
	var opcoes_btn = $VBoxContainer/Opcoes
	var sair_btn = $VBoxContainer/Sair
	
	# Se os botões não estiverem conectados, conectar aos métodos correspondentes
	if iniciar_btn and not iniciar_btn.pressed.is_connected(_on_iniciar_pressed):
		iniciar_btn.pressed.connect(_on_iniciar_pressed)
	
	if opcoes_btn and not opcoes_btn.pressed.is_connected(_on_opcoes_pressed):
		opcoes_btn.pressed.connect(_on_opcoes_pressed)
		
	if sair_btn and not sair_btn.pressed.is_connected(_on_sair_pressed):
		sair_btn.pressed.connect(_on_sair_pressed)
		
	# Obter referências aos serviços
	var service_locator = $"/root/ServiceLocator"
	if service_locator:
		state_manager = service_locator.get_service("StateManager")
		audio_manager = service_locator.get_service("AudioManager")

# Método padrão para iniciar o jogo
func _on_iniciar_pressed():
	if audio_manager:
		audio_manager.play_ui_sound("button_click", "res://assets/audio/ui/button_click.wav")
	
	if state_manager:
		state_manager.change_state("Prologue")
	else:
		push_error("StateManager não encontrado!")

# Método para abrir as opções
func _on_opcoes_pressed():
	if audio_manager:
		audio_manager.play_ui_sound("button_click", "res://scenes/main menu/sfx/UI click.wav")
	
	if state_manager:
		state_manager.change_state("Config")
	else:
		push_error("StateManager não encontrado!")

# Método para sair do jogo
func _on_sair_pressed():
	if audio_manager:
		audio_manager.play_ui_sound("button_click", "res://scenes/main menu/sfx/UI click.wav")
		
	get_tree().quit()
