extends TextureRect

func _ready():
	# Verificar se já existem conexões para os botões
	var iniciar_btn = $VBoxContainer/Iniciar
	var sair_btn = $VBoxContainer/Sair
	
	# Conectar os botões aos nossos métodos sem remover outras conexões
	# Isso permite que tanto o som quanto a navegação funcionem
	if iniciar_btn:
		# Apenas conectar se ainda não estiver conectado
		if not iniciar_btn.pressed.is_connected(_on_iniciar_pressed):
			iniciar_btn.pressed.connect(_on_iniciar_pressed)
	
	if sair_btn:
		# Apenas conectar se ainda não estiver conectado
		if not sair_btn.pressed.is_connected(_on_sair_pressed):
			sair_btn.pressed.connect(_on_sair_pressed)
	
	# Iniciar música de fundo do menu
	AudioManager.play_music("menu")

# Método padrão para iniciar o jogo
func _on_iniciar_pressed():
	# Tocar efeito sonoro de clique
	AudioManager.play_sfx("button_click")	
	# Fade out da música do menu quando inicia o jogo
	AudioManager.stop_music(1.0)
	
	var orquestrador = _get_orquestrador()
	if orquestrador:
		orquestrador.start_prologue()

# Método para sair do jogo
func _on_sair_pressed():
	# Tocar efeito sonoro de clique
	AudioManager.play_sfx("button_click")
	
	var orquestrador = _get_orquestrador()
	if orquestrador:
		orquestrador.quit_game()

# Método auxiliar para obter referência ao orquestrador
func _get_orquestrador():
	var orquestrador = null
	
	# Tenta várias possibilidades de path para o orquestrador
	var possible_paths = [
		"/root/Game/Orquestrador",
		"../Orquestrador",
		"/root/Orquestrador"
	]
	
	for path in possible_paths:
		orquestrador = get_node_or_null(path)
		if orquestrador:
			print("Orquestrador encontrado em: ", path)
			break
	
	if not orquestrador:
		print("Não foi possível encontrar o Orquestrador em nenhum caminho conhecido")
	
	return orquestrador
