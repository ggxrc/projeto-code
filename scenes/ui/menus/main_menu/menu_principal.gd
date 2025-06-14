extends TextureRect

# Referências aos gerenciadores
var state_manager
var audio_manager
var scene_manager

func _ready():
	# Verificar se já existem conexões para os botões
	var iniciar_btn = $VBoxContainer/Iniciar
	var config_btn = $VBoxContainer/Configuracoes
	var creditos_btn = $VBoxContainer/Creditos
	var sair_btn = $VBoxContainer/Sair
	
	# Se os botões não estiverem conectados, conectar aos métodos correspondentes
	if iniciar_btn and not iniciar_btn.pressed.is_connected(_on_iniciar_pressed):
		iniciar_btn.pressed.connect(_on_iniciar_pressed)
		
	if config_btn and not config_btn.pressed.is_connected(_on_configuracoes_pressed):
		config_btn.pressed.connect(_on_configuracoes_pressed)
		
	if creditos_btn and not creditos_btn.pressed.is_connected(_on_creditos_pressed):
		creditos_btn.pressed.connect(_on_creditos_pressed)
		
	if sair_btn and not sair_btn.pressed.is_connected(_on_sair_pressed):
		sair_btn.pressed.connect(_on_sair_pressed)
	
	# Obter referências aos serviços
	var service_locator = $"/root/ServiceLocator"
	if service_locator:
		state_manager = service_locator.get_service("StateManager")
		audio_manager = service_locator.get_service("AudioManager")
		scene_manager = service_locator.get_service("SceneManager")
		
		# Tocar música do menu principal
		if audio_manager:
			audio_manager.play_music("menu_theme", "res://assets/audio/music/menu_theme.ogg", 0.0)
		
		# Configurar o AudioStreamPlayer
		var audio_player = $AudioStreamPlayer
		if audio_player and not audio_player.is_playing():
			audio_player.play()

# Método padrão para iniciar o jogo
func _on_iniciar_pressed():
	if audio_manager:
		audio_manager.play_ui_sound("button_click", "res://assets/audio/ui/button_click.ogg", 1.0)
	
	if state_manager and scene_manager:
		# Mostrar tela de loading
		scene_manager.show_loading_screen("Carregando...")
		# Mudar para o prólogo (a tela de loading será fechada automaticamente quando a cena estiver pronta)
		state_manager.change_state("Prologue")
	else:
		push_error("StateManager ou SceneManager não encontrados!")

# Método para abrir as configurações
func _on_configuracoes_pressed():
	if audio_manager:
		audio_manager.play_ui_sound("button_click", "res://assets/audio/ui/button_click.ogg", 1.0)
	
	if state_manager:
		state_manager.change_state("Config")
	else:
		push_error("StateManager não encontrado!")

# Método para abrir os créditos
func _on_creditos_pressed():
	if audio_manager:
		audio_manager.play_ui_sound("button_click", "res://assets/audio/ui/button_click.ogg", 1.0)
	
	if state_manager:
		state_manager.change_state("Credits")
	else:
		push_error("StateManager não encontrado!")

# Método para sair do jogo
func _on_sair_pressed():
	if audio_manager:
		audio_manager.play_ui_sound("button_click", "res://assets/audio/ui/button_click.ogg", 1.0)
	
	# Esperar um pouco para que o som seja reproduzido antes de sair
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()
