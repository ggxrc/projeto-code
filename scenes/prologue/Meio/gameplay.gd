extends Node

# Referência para o nó de configurações - inicialização adiada para garantir que encontremos o nó
var config = null

# Referências de UI
var dialogue_box = null
var description_box = null
var effects = null
var menu_pausa = null
var transition_screen = null
var loading_screen = null
var pause_button = null
var audio_manager = null

# Estado do jogo
var game_paused = false
# Variável para controlar se a sequência de saída de casa já foi iniciada
var sequencia_saida_casa_iniciada = false
# Referência para o script de sequência
var sequencia_saida_casa = null
# Variável para controlar a sequência do telefone de Jucira
var sequencia_telefone_jucira = null
var sequencia_telefone_iniciada = false

func _ready() -> void:
	print("Cena Gameplay carregada com sucesso!")
	
	# Detectar se estamos rodando como subcena do Game ou independentemente
	var game_parent = get_node_or_null("/root/Game")
	var is_subcena = (get_parent() != get_tree().root)
	
	print("Gameplay rodando como subcena: ", is_subcena)
	print("Game parent encontrado: ", game_parent != null)
	
	# Inicializa referência ao AudioManager
	if Engine.has_singleton("AudioManager"):
		audio_manager = Engine.get_singleton("AudioManager")
		audio_manager.play_music("gameplay", 1.5)
	elif game_parent and game_parent.has_node("AudioManager"):
		audio_manager = game_parent.get_node("AudioManager")
		audio_manager.play_music("gameplay", 1.5)
	
	# Inicialização da referência ao nó de configurações
	_setup_config_reference()
	
	_setup_scene()
	_setup_ui_elements()
	_setup_pause_button()
	
	# Garante que todos os elementos da UI estejam em CanvasLayers
	_ensure_ui_in_canvas_layer()
	
	# Verificar tecla de pausa (ESC)
	if not InputMap.has_action("pause"):
		InputMap.add_action("pause")
		var event = InputEventKey.new()
		event.keycode = KEY_ESCAPE
		InputMap.action_add_event("pause", event)
	
	# Verificação adicional para garantir que o menu de pausa está configurado corretamente
	_fix_pause_menu_hierarchy()

# Função para garantir que temos uma referência válida ao nó de configurações
func _setup_config_reference() -> void:
	var config_path = "ExteriorVizinhos/Player/Camera2D/Config"
	
	if has_node(config_path):
		config = get_node(config_path)
		print("Config encontrado no caminho: ", config_path)
	else:
		print("Aviso: Config não encontrado no caminho esperado, tentando buscar...")
		
		# Tenta encontrar em qualquer lugar da cena
		config = _find_node_recursive(self, "Config")
		
		if config:
			print("Config encontrado através de busca recursiva")
		else:
			print("Aviso: Nenhum nó Config encontrado na cena")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		toggle_pause()

func _setup_scene() -> void:
	var player = get_node_or_null("Player") or find_player_in_scene()
	if player:
		print("Jogador encontrado na cena Gameplay")
	else:
		printerr("Jogador não encontrado na cena Gameplay!")

func _setup_ui_elements() -> void:
	# Configurar elementos de UI principais
	effects = get_node_or_null("Effects")
	if not effects:
		print("AVISO: Nó 'Effects' não encontrado na cena.")
		return
		
	# Configurar menu de pausa - primeiro procura em Effects
	menu_pausa = effects.get_node_or_null("MenuPausa")
	
	# Se não encontrar, tenta localizar no caminho específico da cena
	if not menu_pausa:
		menu_pausa = get_node_or_null("ExteriorVizinhos/Player/Camera2D/Pause/MenuPausa")
		
	if menu_pausa:
		menu_pausa.visible = false
		menu_pausa.process_mode = Node.PROCESS_MODE_ALWAYS
		_connect_pause_menu_signals()
	else:
		print("AVISO: Nó 'MenuPausa' não encontrado nos efeitos ou no caminho esperado.")
	
	# Configurar outros elementos de UI
	transition_screen = effects.get_node_or_null("TransitionScreen")
	loading_screen = effects.get_node_or_null("LoadingScreen")
	
	# Adicionar caixas de diálogo e descrição
	_setup_dialogue_boxes()

func _setup_dialogue_boxes() -> void:
	# Adicionar caixa de diálogo se não existir
	if not get_node_or_null("DialogueBox"):
		dialogue_box = load("res://scenes/diálogos/caixa de diálogos/DialogueBox.tscn").instantiate()
		dialogue_box.name = "DialogueBox"
		add_child(dialogue_box)
		print("Caixa de diálogo adicionada dinamicamente.")
	
	# Adicionar caixa de descrição se não existir
	if not get_node_or_null("DescriptionBox"):
		description_box = load("res://scenes/diálogos/caixa de descrições/DescriptionBox.tscn").instantiate()
		description_box.name = "DescriptionBox"
		add_child(description_box)
		print("Caixa de descrição adicionada dinamicamente.")

func _setup_pause_button() -> void:
	# Procurar botão de pausa existente na cena
	pause_button = get_node_or_null("PauseButton")
	
	# Verificar outros locais comuns se o botão não for encontrado
	if not pause_button:
		var canvas_layers = get_tree().get_nodes_in_group("UI") if get_tree().has_group("UI") else []
		for layer in canvas_layers:
			var found_button = layer.get_node_or_null("PauseButton")
			if found_button:
				pause_button = found_button
				break
				
	if not pause_button:
		var camera = get_node_or_null("Camera2D")
		if camera:
			pause_button = camera.get_node_or_null("PauseButton")
	
	if not pause_button:
		var player = get_node_or_null("Player")
		if player:
			pause_button = player.get_node_or_null("PauseButton")
	
	# Se encontrou o botão de pausa, conectar ao sinal
	if pause_button:
		print("Botão de pausa encontrado na cena: ", pause_button.name)
		# Conectar o sinal
		if pause_button.pressed.is_connected(toggle_pause):
			pause_button.pressed.disconnect(toggle_pause)
		pause_button.pressed.connect(toggle_pause)
		pause_button.process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		print("AVISO: Botão de pausa não encontrado na cena. Não será criado um novo botão.")

# Conecta sinais do menu de pausa
func _connect_pause_menu_signals() -> void:
	if not menu_pausa:
		return
		
	print("Conectando sinais do menu de pausa...")
	
	# Mapeamento de botões para funções
	var button_actions = {
		"Retomar": _on_retomar_pressed,
		"Continuar": _on_retomar_pressed,  # Alternativo para o botão de retomar
		"Config": abrir_configuracoes,
		"MenuPrincipal": voltar_menu_principal,
		"VoltarMenu": voltar_menu_principal,  # Nome alternativo no menu de pausa
		"Sair": sair_jogo,
		"SairPause": sair_jogo,  # Nome alternativo no menu de pausa
		"Reiniciar": reiniciar_cena
	}
	
	# Conectar botões com base no mapeamento
	for button_name in button_actions:
		var btn = _find_button_in_menu_pausa(button_name)
		if btn:
			var action = button_actions[button_name]
			if btn.pressed.is_connected(action):
				btn.pressed.disconnect(action)
			btn.pressed.connect(action)
			print("Botão '", button_name, "' conectado com sucesso")
		else:
			print("AVISO: Botão '", button_name, "' não encontrado no menu de pausa")
	
	# Verificar se é um menu personalizado com sinais
	if menu_pausa.has_signal("continuar_pressed"):
		print("Usando menu personalizado com sinais")
		if not menu_pausa.continuar_pressed.is_connected(_on_retomar_pressed):
			menu_pausa.continuar_pressed.connect(_on_retomar_pressed)
		if not menu_pausa.reiniciar_pressed.is_connected(reiniciar_cena):
			menu_pausa.reiniciar_pressed.connect(reiniciar_cena)
		if not menu_pausa.menu_pressed.is_connected(voltar_menu_principal):
			menu_pausa.menu_pressed.connect(voltar_menu_principal)
		if not menu_pausa.sair_pressed.is_connected(sair_jogo):
			menu_pausa.sair_pressed.connect(sair_jogo)
	
	# Procurar especificamente pelos botões com nomes comuns
	var retomar_buttons = ["Retomar", "Continuar", "Resume"]
	for btn_name in retomar_buttons:
		var btn = _find_button_in_menu_pausa(btn_name)
		if btn:
			print("Conectando botão '", btn_name, "' ao método _on_retomar_pressed")
			if btn.pressed.is_connected(_on_retomar_pressed):
				btn.pressed.disconnect(_on_retomar_pressed)
			btn.pressed.connect(_on_retomar_pressed)
			break

# Método para iniciar a sequência do telefone da Jucira
func iniciar_sequencia_telefone() -> void:
	print("DEBUG: Método iniciar_sequencia_telefone() chamado")
	
	if sequencia_telefone_iniciada:
		print("DEBUG: Sequência do telefone já foi iniciada anteriormente, ignorando")
		return
	
	print("DEBUG: Iniciando sequência do telefone de Jucira")
	sequencia_telefone_iniciada = true
	
	# Verifica se já existe uma instância do script de sequência
	if not sequencia_telefone_jucira:
		print("DEBUG: Criando instância do script jucira_phone_sequence.gd")
		var script_path = "res://scenes/prologue/Meio/jucira_phone_sequence.gd"
		print("DEBUG: Verificando se o script existe:", FileAccess.file_exists(script_path))
		
		sequencia_telefone_jucira = load(script_path).new()
		add_child(sequencia_telefone_jucira)
		print("DEBUG: Script da sequência instanciado e adicionado como filho")
		
		# Conecta os sinais da sequência
		sequencia_telefone_jucira.sequence_started.connect(_on_phone_sequence_started)
		sequencia_telefone_jucira.sequence_finished.connect(_on_phone_sequence_finished)
		print("DEBUG: Sinais conectados")
	
	# Inicia a sequência
	print("DEBUG: Chamando start_sequence()")
	sequencia_telefone_jucira.start_sequence()

# Callback quando a sequência do telefone inicia
func _on_phone_sequence_started() -> void:
	print("Sequência do telefone iniciada")
	# Aqui você pode pausar o jogador, mostrar efeitos visuais, etc.
	
	# Exemplo: desabilitar movimento do jogador durante a sequência
	var player = find_player_in_scene()
	if player and player.has_method("set_can_move"):
		player.set_can_move(false)

# Callback quando a sequência do telefone termina
func _on_phone_sequence_finished() -> void:
	print("Sequência do telefone finalizada")
	# Re-habilitar o jogador, atualizar estado do jogo, etc.
	
	# Exemplo: re-habilitar movimento do jogador após a sequência
	var player = find_player_in_scene()
	if player and player.has_method("set_can_move"):
		player.set_can_move(true)
	
# Função auxiliar para encontrar o jogador em qualquer lugar da cena
func find_player_in_scene() -> Node:
	return _find_node_recursive(self, "Player")

# Função auxiliar para encontrar botões no menu de pausa
func _find_button_in_menu_pausa(button_name: String) -> Button:
	if not menu_pausa:
		return null
	
	# Procurar diretamente
	var btn = menu_pausa.get_node_or_null(button_name)
	if btn and btn is Button:
		return btn
	
	# Procurar em containers comuns e caminhos específicos conhecidos
	var possible_paths = [
		# Caminhos diretos
		button_name,
		# Caminhos comuns em containers
		"VBoxContainer/" + button_name,
		"Control/VBoxContainer/" + button_name,
		"Control/Background/VBoxContainer/" + button_name,
		# Caminhos com nomes de botões alternativos para compatibilidade
		"Control/Background/VBoxContainer/Retomar",
		"Control/Background/VBoxContainer/Config",
		"Control/Background/VBoxContainer/VoltarMenu",
		"Control/Background/VBoxContainer/SairPause"
	]
	
	for path in possible_paths:
		btn = menu_pausa.get_node_or_null(path)
		if btn and btn is Button:
			print("Botão encontrado em: ", path)
			return btn
	
	# Se não encontrou por caminhos diretos, tenta procura recursiva
	return _find_button_recursive(menu_pausa, button_name)

# Função genérica para procurar qualquer nó recursivamente
func _find_node_recursive(node: Node, node_name: String) -> Node:
	if not node:
		return null
	
	if node.name == node_name:
		return node
		
	for child in node.get_children():
		var result = _find_node_recursive(child, node_name)
		if result:
			return result
	
	return null

# Função para garantir que todos os elementos de UI estejam em CanvasLayers
func _ensure_ui_in_canvas_layer() -> void:
	# Lista de elementos da UI para verificar
	var ui_elements = {
		"menu_pausa": menu_pausa,
		"transition_screen": transition_screen,
		"loading_screen": loading_screen,
		"dialogue_box": dialogue_box,
		"description_box": description_box,
		"config": config
	}
	
	# Para cada elemento da UI
	for element_name in ui_elements:
		var element = ui_elements[element_name]
		if element:
			var parent = element.get_parent()
			
			# Se o pai não é um CanvasLayer, movemos para um
			if not parent is CanvasLayer:
				print("Movendo ", element_name, " para um CanvasLayer dedicado...")
				
				# Remover o elemento do pai atual (sem apagar)
				parent.remove_child(element)
				
				# Criar novo CanvasLayer
				var canvas_layer = CanvasLayer.new()
				canvas_layer.name = element_name.capitalize() + "Layer"
				canvas_layer.layer = 10  # Layer alta para ficar acima do jogo
				canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS
				
				# Adicionar o elemento ao novo CanvasLayer
				canvas_layer.add_child(element)
				
				# Adicionar o CanvasLayer à cena
				add_child(canvas_layer)
				
				print(element_name, " agora está em um CanvasLayer e não será afetado pela câmera")

# Alterna o estado de pausa do jogo
func toggle_pause() -> void:
	# Priorizar o Game parent se estiver disponível
	var game_parent = get_node_or_null("/root/Game")
	
	# Se estamos rodando como subcena do Game, delegar para ele
	if game_parent and get_parent() == game_parent:
		print("Delegando controle de pausa ao Game parent...")
		if game_parent.has_method("pause_game") and game_parent.has_method("_on_retomar_pressed"):
			if game_paused:
				# Se já está pausado, despause
				if AudioManager:
					AudioManager.play_sfx("button_click")
				game_parent._on_retomar_pressed()
			else:
				# Se não está pausado, pause
				if AudioManager:
					AudioManager.play_sfx("button_click")
				game_parent.pause_game()
			return
	
	# Verificar se existe um Orquestrador (compatibilidade com sistema antigo)
	var orquestrador = get_node_or_null("/root/Game/Orquestrador")
	if orquestrador and orquestrador.has_method("pause_game") and orquestrador.has_method("_on_retomar_pressed"):
		print("Delegando controle de pausa ao orquestrador...")
		if game_paused:
			# Se já está pausado, despause
			if AudioManager:
				AudioManager.play_sfx("button_click")
			orquestrador._on_retomar_pressed()
		else:
			# Se não está pausado, pause
			if AudioManager:
				AudioManager.play_sfx("button_click")
			orquestrador.pause_game()
		return
	
	# Se não encontrou sistemas superiores, continua com a implementação local
	print("Alternando pausa localmente...")
	game_paused = !game_paused
	
	# Verificar se get_tree() não é null antes de acessá-lo
	var tree = get_tree()
	if tree:
		tree.paused = game_paused
	else:
		print("ERRO: get_tree() retornou null ao tentar alternar pausa!")
	
	if AudioManager:
		AudioManager.play_sfx("button_click")
	
	if menu_pausa:
		print("Atualizando estado do menu de pausa: ", game_paused)
		
		# Garantir que o menu de pausa esteja visível quando pausado
		menu_pausa.visible = game_paused
		
		# Garantir que o menu de pausa está no modo de processo correto
		menu_pausa.process_mode = Node.PROCESS_MODE_ALWAYS if game_paused else Node.PROCESS_MODE_DISABLED
		
		# Se o menu_pausa não estiver aparecendo, verificamos se precisamos mudar o layer
		if game_paused:
			menu_pausa.layer = 100  # Define um layer alto para o CanvasLayer
			menu_pausa.follow_viewport_enabled = false  # Desativa o follow_viewport
		
		# Atualizar visibilidade em controles adicionais
		var control = menu_pausa.get_node_or_null("Control")
		if control:
			control.visible = game_paused
			
			# Se o jogo está pausado, garantimos que o controle ocupe toda a tela
			if game_paused:
				control.anchors_preset = Control.PRESET_FULL_RECT
				control.anchor_right = 1.0
				control.anchor_bottom = 1.0
				control.offset_right = 0
				control.offset_bottom = 0
				control.size = Vector2(1280, 720)
				control.position = Vector2.ZERO
				
				# Garantir que o background do menu de pausa ocupe toda a tela
				var background = control.get_node_or_null("Background")
				if background:
					background.anchors_preset = Control.PRESET_FULL_RECT
					background.anchor_right = 1.0
					background.anchor_bottom = 1.0
					background.offset_right = 0
					background.offset_bottom = 0
					background.size = Vector2(1280, 720)
					background.position = Vector2.ZERO
				
	print("Estado de pausa: ", game_paused)

# Reinicia a cena atual
func reiniciar_cena() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

# Volta para o menu principal mantendo a gameplay pausada em segundo plano
func voltar_menu_principal() -> void:
	print("Voltando para menu principal...")
	
	# Se estamos rodando como subcena do Game, delegar para ele
	var game_parent = get_node_or_null("/root/Game")
	if game_parent and get_parent() == game_parent:
		print("Delegando volta ao menu para Game parent...")
		if game_parent.has_method("navigate_to_main_menu"):
			game_parent.navigate_to_main_menu("loading")
			return
	
	# Implementação local para quando rodando independentemente
	print("Mostrando menu principal localmente e mantendo gameplay pausada...")
	
	# Esconde o menu de pausa se estiver visível
	_hide_pause_menu()
	if config and config.has_node("CanvasLayer") and config.get_node("CanvasLayer").visible:
		config.get_node("CanvasLayer").visible = false
	get_tree().paused = true
	
	# Obtém a cena do menu principal
	var menu_principal = load("res://scenes/main menu/MenuPrincipal.tscn").instantiate()
	
	# Adiciona o menu por cima da gameplay atual usando uma nova CanvasLayer
	var menu_layer = CanvasLayer.new()
	menu_layer.name = "MenuPrincipalLayer"
	menu_layer.layer = 120  # Layer mais alta para ficar acima do menu de pausa e das configurações
	menu_layer.process_mode = Node.PROCESS_MODE_ALWAYS  # Permite interagir mesmo com o jogo pausado
	
	menu_layer.add_child(menu_principal)
	add_child(menu_layer)
	
	# Guarda a referência para poder voltar à gameplay facilmente
	if not get_tree().get_root().has_meta("gameplay_scene"):
		get_tree().get_root().set_meta("gameplay_scene", self)
		print("Referência para gameplay guardada com sucesso")

# Sai do jogo
func sair_jogo() -> void:
	# Verificar se estamos rodando como subcena do Game
	var game_parent = get_node_or_null("/root/Game")
	if game_parent and get_parent() == game_parent:
		print("Delegando saída do jogo para Game parent...")
		if game_parent.has_method("trigger_quit_game"):
			game_parent.trigger_quit_game()
			return
	
	# Verificar se existe um sistema de orquestração (compatibilidade)
	var orquestrador = get_node_or_null("/root/Game/Orquestrador")
	
	if game_parent and game_parent.has_method("quit_game"):
		# Se existe um Game com método quit_game, usamos ele
		print("Saindo do jogo via Game controller...")
		game_parent.quit_game()
	elif orquestrador and orquestrador.has_method("quit_game"):
		# Se existe um Orquestrador, usamos ele
		print("Saindo do jogo via Orquestrador...")
		orquestrador.quit_game()
	else:
		# Fallback para o método simples
		print("Saindo do jogo diretamente...")
		get_tree().quit()

# Abre a tela de configurações
func abrir_configuracoes() -> void:
	print("Abrindo configurações...")
	
	# Esconder o menu de pausa se estiver visível
	if menu_pausa and menu_pausa.visible:
		menu_pausa.visible = false
		print("Menu de pausa escondido para exibir configurações")
	
	# Verificar se temos o nó de configurações já referenciado na cena específica
	var config_path = "ExteriorVizinhos/Player/Camera2D/Config"
	if has_node(config_path):
		config = get_node(config_path)
		print("Config encontrado no path específico:", config_path)
	
	# Verificar se temos o nó de configurações já referenciado
	if config:
		# Garantir que o config tenha alta prioridade de layer
		var canvas = config.get_node_or_null("CanvasLayer")
		if canvas:
			canvas.layer = 110  # Maior que o layer do menu de pausa (100)
			canvas.visible = true  # Torna o CanvasLayer visível
		
		print("Exibindo nó de configurações existente")
		return
	
	# Caso não tenhamos o nó, tentamos carregar a cena
	var config_scene = "res://scenes/configurações/config.tscn"
	if ResourceLoader.exists(config_scene):
		# Pausar o jogo enquanto estamos nas configurações
		get_tree().paused = true
		
		# Carregar a cena de configurações
		var config_instance = load(config_scene).instantiate()
		config = config_instance
		
		# Configurar layer alta para o CanvasLayer das configurações
		var canvas = config_instance.get_node_or_null("CanvasLayer")
		if canvas:
			canvas.layer = 110  # Maior que o layer do menu de pausa (100)
		
		# Adicionar à árvore
		add_child(config_instance)
		
		print("Nova instância de configurações adicionada à cena")
	else:
		print("AVISO: Cena de configurações não encontrada no caminho:", config_scene)

# Mostra uma mensagem na caixa de descrição
func mostrar_descricao(texto: String, velocidade: float = 0.03) -> void:
	var box = get_node_or_null("DescriptionBox")
	if box:
		box.show_description(texto, velocidade)
	else:
		printerr("Caixa de descrição não encontrada!")

# Busca recursiva por um botão
func _find_button_recursive(node: Node, button_name: String) -> Button:
	if not node:
		return null
		
	for child in node.get_children():
		if child.name == button_name and child is Button:
			return child
			
		var result = _find_button_recursive(child, button_name)
		if result:
			return result
			
	return null

# Chamado quando o botão de pausa é pressionado
func _on_pause_button_pressed() -> void:
	toggle_pause()

# Sinais para os botões
func _on_retomar_pressed() -> void:
	print("Botão Retomar pressionado")
	# Tocar som de clique
	AudioManager.play_sfx("button_click")
	
	# Despausar o jogo com segurança
	game_paused = false
	
	# Esconder o menu de pausa com segurança
	if menu_pausa:
		menu_pausa.visible = false
		
		# Se o menu de pausa tem um nó Control, atualizar sua visibilidade
		var control = menu_pausa.get_node_or_null("Control")
		if control:
			control.visible = false
		
		# Definir modo de processo para desativar
		menu_pausa.process_mode = Node.PROCESS_MODE_DISABLED
		
		print("Menu de pausa escondido após pressionar Retomar")
		
	# Debug: verificar estado de pausa

func _on_config_pressed() -> void:
	print("Botão Config pressionado")
	
	# Esconde o menu de pausa antes de abrir as configurações
	if menu_pausa:
		menu_pausa.visible = false
		
	# Mantém o estado de pausa mas esconde o menu
	abrir_configuracoes()

func _on_voltar_menu_pressed() -> void:
	print("Botão Menu Principal pressionado")
	
	# Esconde o menu de pausa antes de voltar ao menu principal
	if menu_pausa and menu_pausa.visible:
		menu_pausa.visible = false
	
	voltar_menu_principal()

func _on_sair_pause_pressed() -> void:
	print("Botão Sair pressionado")
	
	# Esconde o menu de pausa antes de sair do jogo
	if menu_pausa and menu_pausa.visible:
		_hide_pause_menu()
		
	# Executa o procedimento de saída do jogo
	sair_jogo()

# Função auxiliar para esconder o menu de pausa
func _hide_pause_menu() -> void:
	if menu_pausa:
		menu_pausa.visible = false
		
		# Se o menu de pausa tem um nó Control, atualizar sua visibilidade
		var control = menu_pausa.get_node_or_null("Control")
		if control:
			control.visible = false
			
			# Esconder também os filhos para garantir
			var background = control.get_node_or_null("Background")
			if background:
				background.visible = true  # Mantém visível para o controle principal
				
				# Esconde os elementos específicos que possam estar causando problemas
				var vbox = background.get_node_or_null("VBoxContainer") 
				if vbox:
					# Mantém o VBox visível, mas certifica que os botões funcionarão na próxima exibição
					vbox.visible = true
		
		print("Menu de pausa escondido")
	else:
		print("Menu de pausa não encontrado para esconder")
			
	# Nota: NÃO modificamos game_paused aqui, isso é gerenciado pela função toggle_pause

# Função auxiliar para esconder o menu de configurações
func _hide_config_menu() -> void:
	if config:
		print("Escondendo menu de configurações")
		
		# Esconder o CanvasLayer das configurações
		if config.has_node("CanvasLayer"):
			config.get_node("CanvasLayer").visible = false
			
	# Força a visibilidade do menu de pausa se o jogo estiver pausado
	_force_show_pause_menu()
	
	print("Menu de configurações escondido")

# Nova função para forçar a exibição do menu de pausa
func _force_show_pause_menu() -> void:
	# Forçamos o estado pausado para garantir que o menu de pausa apareça
	game_paused = true
	get_tree().paused = true
	
	print("Forçando exibição do menu de pausa")
	
	# Se ainda não temos o menu_pausa, tenta encontrá-lo
	if not menu_pausa:
		var possible_paths = [
			"ExteriorVizinhos/Player/Camera2D/Pause/MenuPausa",
			"Effects/MenuPausa"
		]
		
		for path in possible_paths:
			if has_node(path):
				menu_pausa = get_node(path)
				print("Menu de pausa encontrado em: ", path)
				break
	
	if menu_pausa:
		# Configura o menu de pausa para exibição
		menu_pausa.visible = true
		menu_pausa.process_mode = Node.PROCESS_MODE_ALWAYS
		menu_pausa.layer = 100
		menu_pausa.follow_viewport_enabled = false
		
		# Garante que o Control e Background estão visíveis
		var control = menu_pausa.get_node_or_null("Control")
		if control:
			control.visible = true
			control.size = Vector2(1280, 720)
			
			var background = control.get_node_or_null("Background")
			if background:
				background.visible = true
				background.size = Vector2(1280, 720)
		
		print("Menu de pausa exibido com sucesso")
	else:
		print("Menu de pausa não encontrado para exibição")

# Função que garante que o menu de pausa esteja configurado corretamente na hierarquia
func _fix_pause_menu_hierarchy() -> void:
	# Procura pelo menu de pausa em diferentes locais possíveis
	var pause_menu = get_node_or_null("ExteriorVizinhos/Player/Camera2D/Pause/MenuPausa")
	
	# Se não encontrar no local específico, tenta em Effects
	if not pause_menu and effects:
		pause_menu = effects.get_node_or_null("MenuPausa")
	
	# Se ainda não encontrou, tenta instanciar um novo
	if not pause_menu:
		print("Menu de pausa não encontrado, tentando instanciar um novo...")
		var menu_pausa_scene = load("res://scenes/menu pausa/MenuPausa.tscn")
		if menu_pausa_scene:
			# Criar um novo nó para o menu de pausa
			var pause_node = Node.new()
			pause_node.name = "Pause"
			pause_node.process_mode = Node.PROCESS_MODE_ALWAYS
			
			if not has_node("Effects"):
				var effects_node = Node.new()
				effects_node.name = "Effects"
				add_child(effects_node)
				effects = effects_node
			
			effects.add_child(pause_node)
			
			pause_menu = menu_pausa_scene.instantiate()
			pause_node.add_child(pause_menu)
			menu_pausa = pause_menu
			_connect_pause_menu_signals()
		else:
			print("Erro: Não foi possível carregar a cena do menu de pausa")
	else:
		menu_pausa = pause_menu
	
	if pause_menu:
		print("Corrigindo configuração do menu de pausa...")
		
		# Garantir que o CanvasLayer do menu de pausa tenha layer alta
		pause_menu.layer = 100
		
		# Garantir que o follow_viewport_enabled esteja desativado
		pause_menu.follow_viewport_enabled = false
		
		# Garantir que o processo mode esteja correto
		pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
		
		# Verificar se o Control existe e está configurado corretamente
		var control = pause_menu.get_node_or_null("Control")
		if control:
			# Redefinir o tamanho e posição
			control.anchors_preset = Control.PRESET_FULL_RECT
			control.anchor_right = 1.0
			control.anchor_bottom = 1.0
			control.offset_right = 0
			control.offset_bottom = 0
			control.size = Vector2(1280, 720)
			
			# Configurar o background
			var background = control.get_node_or_null("Background")
			if background:
				background.anchors_preset = Control.PRESET_FULL_RECT
				background.anchor_right = 1.0
				background.anchor_bottom = 1.0
				background.offset_right = 0
				background.offset_bottom = 0
				background.size = Vector2(1280, 720)
		
		# Ocultar o menu no início
		pause_menu.visible = false
		
		print("Menu de pausa reconfigurado com sucesso!")
	else:
		print("Menu de pausa não encontrado para reconfiguração.")

# Função específica para ser chamada pelo botão voltar das configurações
func _on_voltar_from_config_pressed() -> void:
	print("Gameplay: Botão Voltar das configurações pressionado diretamente")
	
	# Tocar som de clique
	if audio_manager:
		audio_manager.play_sfx("button_click")
	
	# Verificar referência ao config
	if not config:
		_setup_config_reference()
	
	# Esconder configurações
	if config and config.has_node("CanvasLayer"):
		config.get_node("CanvasLayer").visible = false
		print("Gameplay: Canvas Layer das configurações escondido com sucesso")
	else:
		print("Gameplay: Não foi possível encontrar o CanvasLayer das configurações")
	
	# Mostrar menu de pausa se estiver pausado
	_force_show_pause_menu()
	print("Gameplay: Menu de pausa restaurado")

# Iniciar a sequência de diálogos quando o jogador sai da casa
func iniciar_sequencia_saida_casa() -> void:
	print("Iniciando sequência de saída da casa no gameplay...")
	
	# Evitar iniciar a sequência mais de uma vez
	if sequencia_saida_casa_iniciada:
		print("Sequência de saída já foi iniciada anteriormente!")
		return
	
	sequencia_saida_casa_iniciada = true
	
	# Criar instância do script de sequência
	var sequencia_script = load("res://scenes/prologue/Meio/sequencia_saida_casa.gd")
	if not sequencia_script:
		push_error("Não foi possível carregar o script sequencia_saida_casa.gd!")
		return
	
	sequencia_saida_casa = sequencia_script.new()
	add_child(sequencia_saida_casa)
	
	# Conectar sinal de conclusão da sequência
	if sequencia_saida_casa.has_signal("sequencia_completa"):
		sequencia_saida_casa.connect("sequencia_completa", _on_sequencia_saida_casa_concluida)
	
	# Imprimir métodos disponíveis para debug
	print("Métodos disponíveis no script de sequência: ", _get_available_methods(sequencia_saida_casa))
	
	# Iniciar a sequência
	if sequencia_saida_casa.has_method("iniciar_sequencia"):
		print("Chamando método iniciar_sequencia() do script sequencia_saida_casa")
		sequencia_saida_casa.iniciar_sequencia()
	else:
		push_error("O script de sequência não possui o método iniciar_sequencia!")
		
		# Como alternativa, tentar iniciar os diálogos diretamente
		print("Tentando chamar métodos de diálogo individualmente como alternativa")
		if sequencia_saida_casa.has_method("mostrar_dialogo_inicial"):
			sequencia_saida_casa.desativar_controles_jogador()
			sequencia_saida_casa.mostrar_dialogo_inicial()
		else:
			push_error("O script de sequência não possui os métodos necessários!")

# Função auxiliar para obter métodos disponíveis de um nó (para debug)
func _get_available_methods(node):
	var methods = []
	for method in node.get_method_list():
		methods.append(method["name"])
	return methods

# Quando a sequência terminar
func _on_sequencia_saida_casa_concluida():
	print("Sequência de saída da casa concluída!")
	
	# Adicionar quaisquer ações adicionais após a conclusão da sequência aqui
	# Por exemplo, atualizar estados de missão, desbloquear novos objetivos, etc.

# Função para verificar e reportar o estado do orquestrador e do sistema de pausa
func _debug_pause_system() -> void:
	print("=== DEPURAÇÃO DO SISTEMA DE PAUSA ===")
	print("Estado local de pausa (game_paused):", game_paused)
	
	var tree = get_tree()
	print("get_tree() é válido?", tree != null)
	if tree:
		print("get_tree().paused =", tree.paused)
	
	var orquestrador = get_node_or_null("/root/Game")
	print("Orquestrador encontrado?", orquestrador != null)
	if orquestrador:
		print("Orquestrador tem método pause_game?", orquestrador.has_method("pause_game"))
		print("Orquestrador tem método _on_retomar_pressed?", orquestrador.has_method("_on_retomar_pressed"))
		if "current_state" in orquestrador:
			print("Estado atual do orquestrador:", orquestrador.current_state)
	
	print("menu_pausa é válido?", menu_pausa != null)
	if menu_pausa:
		print("menu_pausa.visible =", menu_pausa.visible)
		print("menu_pausa.process_mode =", menu_pausa.process_mode)
	print("===============================")
