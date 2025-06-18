extends Node

# Referências para os sliders de volume
@onready var music_slider = $CanvasLayer/Control/ColorRect/MusicBar/HSlider
@onready var sfx_slider = $CanvasLayer/Control/ColorRect/SfxBar/HSlider
@onready var voltar_button = $CanvasLayer/Control/VoltarFromConfig

func _ready() -> void:
	print("Config: Inicializando tela de configurações")
	
	# Define um volume mínimo para exibição (evita sliders zerados)
	var min_display_volume = 0.05  # 5% como mínimo
	
	# Conecta os sinais dos sliders
	if music_slider:
		music_slider.value_changed.connect(_on_music_volume_changed)
		# Inicializa com o valor atual do AudioManager (garantindo mínimo sensato)
		var music_vol = max(AudioManager.music_volume, min_display_volume)
		music_slider.value = music_vol * 100
		print("Config: Slider de música configurado com valor inicial: ", music_slider.value)
	else:
		push_error("Config: Slider de música não encontrado!")
	
	if sfx_slider:
		sfx_slider.value_changed.connect(_on_sfx_volume_changed)
		# Inicializa com o valor atual do AudioManager (garantindo mínimo sensato)
		var sfx_vol = max(AudioManager.sfx_volume, min_display_volume)
		sfx_slider.value = sfx_vol * 100
		print("Config: Slider de SFX configurado com valor inicial: ", sfx_slider.value)
	else:
		push_error("Config: Slider de SFX não encontrado!")
			
	# Conecta o botão de voltar
	if voltar_button:
		voltar_button.pressed.connect(_on_voltar_pressed)
		print("Config: Botão de voltar configurado")
	else:
		push_error("Config: Botão de voltar não encontrado!")

func _on_music_volume_changed(value: float) -> void:
	print("Config: Alterando volume da música para ", value)
	AudioManager.set_music_volume(value / 100)  # Converte de 0-100 para 0-1
	
	# Tocar música de exemplo se não houver música tocando
	if not AudioManager.music_player.playing:
		print("Config: Tocando música de exemplo para teste")
		AudioManager.play_music("menu")

func _on_sfx_volume_changed(value: float) -> void:
	print("Config: Alterando volume de SFX para ", value)
	AudioManager.set_sfx_volume(value / 100)  # Converte de 0-100 para 0-1
	
	# Tocar um som para testar o volume
	AudioManager.play_sfx("button_click")

func _on_voltar_pressed() -> void:
	# Reproduz som de clique
	AudioManager.play_sfx("button_click")
	
	# Salva as configurações antes de sair
	_save_audio_settings()
	
	print("Config: Botão Voltar pressionado - fechando configurações")
	
	# SOLUÇÃO ULTRA DIRETA: Esconde as configurações imediatamente
	if has_node("CanvasLayer"):
		$CanvasLayer.visible = false
	
	# Método 1: Usar o owner se este nó for parte de uma instância da cena Gameplay
	var owner_node = get_owner()
	if owner_node and owner_node.has_method("_on_voltar_from_config_pressed"):
		print("Config: Chamando método do owner")
		owner_node._on_voltar_from_config_pressed()
		return
		
	# Método 2: Procurar pelo nó pai ou avô que possa ser a cena Gameplay
	var parent_node = get_parent()
	while parent_node:
		if parent_node.has_method("_on_voltar_from_config_pressed"):
			print("Config: Chamando método do nó pai: ", parent_node.name)
			parent_node._on_voltar_from_config_pressed()
			return
		parent_node = parent_node.get_parent()
	
	# Método 3: Tenta encontrar a cena Gameplay no topo da árvore
	var root = get_tree().get_root()
	for i in range(root.get_child_count() - 1, -1, -1):  # Percorre de trás para frente
		var node = root.get_child(i)
		# Verifica se é a cena Gameplay
		if node.get_script() and node.get_script().get_path().find("gameplay.gd") != -1:
			if node.has_method("_on_voltar_from_config_pressed"):
				print("Config: Chamando função específica do gameplay para voltar")
				node._on_voltar_from_config_pressed()
				return
	
	# Se não conseguir chamar diretamente, usa o método complexo
	_force_return_to_pause_menu()
	
	# SOLUÇÃO DIRETA: Procura o menu de pausa na cena
	var menu_pausa = null
	
	# Primeiro tenta pelo caminho específico conhecido
	var gameplay = get_node_or_null("/root/Gameplay")  # Pode ser Gameplay ou outro nome
	if not gameplay:
		# Se não encontrou, tenta obter o nó raiz da cena 
		gameplay = get_tree().get_current_scene()
	
	if gameplay:
		# Busca pelo menu de pausa na cena de Gameplay
		print("Config: Procurando menu de pausa na cena de Gameplay")
		
		# Primeiro procura diretamente
		menu_pausa = gameplay.get_node_or_null("ExteriorVizinhos/Player/Camera2D/Pause/MenuPausa")
		
		# Se não encontrar, procura por outros menus de pausa na cena
		if not menu_pausa:
			print("Config: Procurando MenuPausa na árvore de nós")
			
			# Procura pelo nome "MenuPausa" ou por um nó com script que contenha "menu_pausa"
			var queue = [gameplay]
			while queue.size() > 0 and not menu_pausa:
				var current = queue.pop_front()
				
				if current.name == "MenuPausa" or (current.name.to_lower().contains("menu") and current.name.to_lower().contains("pausa")):
					menu_pausa = current
					break
				
				for child in current.get_children():
					queue.push_back(child)
	
	# Se encontrou o menu de pausa, mostra ele
	if menu_pausa:
		print("Config: Menu de pausa encontrado, tornando-o visível")
		menu_pausa.visible = true
		
		# Garantir configurações corretas para o menu de pausa
		menu_pausa.layer = 100  # Layer alta
		menu_pausa.follow_viewport_enabled = false
		
		# Garantir que o Control dentro do menu de pausa esteja visível
		var control = menu_pausa.get_node_or_null("Control")
		if control:
			control.visible = true
		
		print("Config: Menu de pausa restaurado com sucesso")
	else:
		print("Config: Menu de pausa não encontrado")
		
	# Verifica se há uma variável game_paused na cena principal
	if gameplay and "game_paused" in gameplay:
		print("Config: A cena de gameplay tem uma variável game_paused")
		# Manter o jogo pausado
		get_tree().paused = true
	
	print("Config: Configurações fechadas com sucesso")
func _save_audio_settings() -> void:
	print("Config: Salvando configurações de áudio")
	
	var config = ConfigFile.new()
	
	# Define os valores a serem salvos
	config.set_value("audio", "music_volume", AudioManager.music_volume)
	config.set_value("audio", "sfx_volume", AudioManager.sfx_volume)
	config.set_value("audio", "master_volume", AudioManager.master_volume)
	
	# Salva o arquivo
	var err = config.save("user://audio_settings.cfg")
	if err != OK:
		push_error("Config: Erro ao salvar configurações de áudio: " + str(err))
	else:
		print("Config: Configurações salvas com sucesso.")

# Método auxiliar para obter referência ao orquestrador
func _get_orquestrador():
	var orquestrador = null
	
	# Tenta várias possibilidades de path para o orquestrador
	var possible_paths = [
		"/root/Game/Orquestrador",
		"../Orquestrador",
		"/root/Orquestrador",
		"/root/Game"
	]
	
	for path in possible_paths:
		orquestrador = get_node_or_null(path)
		if orquestrador:
			print("Orquestrador encontrado em: ", path)
			break
	
	if not orquestrador:
		print("Não foi possível encontrar o Orquestrador em nenhum caminho conhecido")
	
	return orquestrador

# Função para forçar o retorno ao menu de pausa
func _force_return_to_pause_menu() -> void:
	print("Config: Forçando retorno ao menu de pausa")
	
	# Método 1: Tenta obter a cena Gameplay diretamente
	var gameplay = get_tree().get_current_scene()
	
	# Verifica se é a cena de gameplay mesmo
	if gameplay and gameplay.get_script() and gameplay.get_script().get_path().find("gameplay.gd") != -1:
		print("Config: Cena gameplay encontrada diretamente")
		
		# Se tiver a função para forçar menu de pausa, chama ela
		if gameplay.has_method("_force_show_pause_menu"):
			gameplay._force_show_pause_menu()
			print("Config: Chamou _force_show_pause_menu() diretamente")
			return
	
	# Método 2: Tenta alternativas
	
	# Acha qualquer nó na árvore com "Player" no nome
	var player_nodes = get_tree().get_nodes_in_group("Player")
	if player_nodes.size() > 0:
		var player = player_nodes[0]
		
		# Busca um MenuPausa nos filhos da câmera do player
		if player.has_node("Camera2D"):
			var camera = player.get_node("Camera2D")
			
			if camera.has_node("Pause/MenuPausa"):
				var menu = camera.get_node("Pause/MenuPausa")
				menu.visible = true
				print("Config: MenuPausa encontrado e exibido via Camera2D do player")
				return
	
	# Método 3: SUPER DIRETO - busca qualquer MenuPausa na árvore
	var all_nodes = get_tree().get_nodes_in_group("UI")
	for node in all_nodes:
		if node.name == "MenuPausa" or (node.name.to_lower().contains("menu") and node.name.to_lower().contains("pause")):
			node.visible = true
			print("Config: MenuPausa encontrado e exibido (método direto)")
			return
	
	# Método 4: Tenta chamar o toggle_pause no gameplay
	if gameplay and gameplay.has_method("toggle_pause"):
		# Guarda o estado da pausa só para registro
		var _paused_before = get_tree().paused
		get_tree().paused = false  # Despausar momentaneamente
		
		# Chamar toggle_pause para forçar a reabertura do menu de pausa
		gameplay.toggle_pause()
		
		# Garantir que o jogo está pausado
		if not get_tree().paused:
			get_tree().paused = true
		
		print("Config: Usado toggle_pause para forçar abertura do menu")
		return
		
	print("Config: Não foi possível forçar o retorno ao menu de pausa")
