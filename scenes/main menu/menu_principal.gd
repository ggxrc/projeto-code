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
	
	# Verificar se há uma gameplay em pausa
	if get_tree().get_root().has_meta("gameplay_scene"):
		print("Voltando para a gameplay que estava pausada...")
		
		# Obter referência para a cena de gameplay
		var gameplay_scene = get_tree().get_root().get_meta("gameplay_scene")
		
		# Garantir que o menu de pausa está escondido antes de retornar
		if gameplay_scene.has_method("_hide_pause_menu"):
			gameplay_scene._hide_pause_menu()
		elif "menu_pausa" in gameplay_scene and gameplay_scene.menu_pausa:
			gameplay_scene.menu_pausa.visible = false
			print("Escondendo menu de pausa antes de retornar")
		
		# Remover o menu principal da árvore
		var parent_layer = get_parent()
		if parent_layer and parent_layer.name == "MenuPrincipalLayer":
			parent_layer.queue_free()
		else:
			# Se não estamos em um CanvasLayer específico, só removemos a nós mesmos
			queue_free()
			
		# Despausar o jogo para continuar de onde parou
		get_tree().paused = false
		
		# Garantir que a flag game_paused da gameplay é atualizada
		if "game_paused" in gameplay_scene:
			gameplay_scene.game_paused = false
			print("Flag game_paused da gameplay atualizada para false")
		
		return
	
	# Se não há gameplay pausada, iniciamos um novo jogo
	print("Iniciando novo jogo...")
	var orquestrador = _get_orquestrador()
	if orquestrador:
		orquestrador.start_prologue()

# Método para sair do jogo
func _on_sair_pressed():
	# Tocar efeito sonoro de clique
	AudioManager.play_sfx("button_click")
	
	# Verificar se tem gameplay pausada
	if get_tree().get_root().has_meta("gameplay_scene"):
		# Limpar a referência da gameplay
		get_tree().get_root().remove_meta("gameplay_scene")
	
	# Sair do jogo
	var orquestrador = _get_orquestrador()
	if orquestrador:
		# Tenta usar o orquestrador para sair
		orquestrador.quit_game()
	else:
		# Fallback para o método direto
		get_tree().quit()

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
