extends Node

@onready var config = $Config/CanvasLayer

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

func _ready() -> void:
	print("Cena Gameplay carregada com sucesso!")
	
	# Inicializa referência ao AudioManager
	if Engine.has_singleton("AudioManager"):
		audio_manager = Engine.get_singleton("AudioManager")
		audio_manager.play_music("gameplay", 1.5)
	
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
		
	# Configurar menu de pausa
	menu_pausa = effects.get_node_or_null("MenuPausa")
	if menu_pausa:
		menu_pausa.visible = false
		menu_pausa.process_mode = Node.PROCESS_MODE_ALWAYS
		_connect_pause_menu_signals()
	else:
		print("AVISO: Nó 'MenuPausa' não encontrado nos efeitos.")
	
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

func _connect_pause_menu_signals() -> void:
	if not menu_pausa:
		return
		
	print("Conectando sinais do menu de pausa...")
	
	# Mapeamento de botões para funções
	var button_actions = {
		"Retomar": toggle_pause,
		"Continuar": toggle_pause,
		"Config": abrir_configuracoes,
		"MenuPrincipal": voltar_menu_principal,
		"Sair": sair_jogo,
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
		if not menu_pausa.continuar_pressed.is_connected(toggle_pause):
			menu_pausa.continuar_pressed.connect(toggle_pause)
		if not menu_pausa.reiniciar_pressed.is_connected(reiniciar_cena):
			menu_pausa.reiniciar_pressed.connect(reiniciar_cena)
		if not menu_pausa.menu_pressed.is_connected(voltar_menu_principal):
			menu_pausa.menu_pressed.connect(voltar_menu_principal)
		if not menu_pausa.sair_pressed.is_connected(sair_jogo):
			menu_pausa.sair_pressed.connect(sair_jogo)

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
	
	# Procurar em containers comuns
	var containers = [
		menu_pausa.get_node_or_null("VBoxContainer"),
		menu_pausa.get_node_or_null("Control"),
		menu_pausa.get_node_or_null("Control/VBoxContainer")
	]
	
	for container in containers:
		if container and container.get_node_or_null(button_name) is Button:
			return container.get_node_or_null(button_name)
	
	# Procura recursiva
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

# Alterna o estado de pausa do jogo
func toggle_pause() -> void:
	game_paused = !game_paused
	get_tree().paused = game_paused
	
	if audio_manager:
		audio_manager.play_sfx("button_click")
	
	if menu_pausa:
		menu_pausa.visible = game_paused
		
		# Atualizar visibilidade em controles adicionais
		if menu_pausa.has_method("set_visible"):
			menu_pausa.set_visible(game_paused)
			
		var control = menu_pausa.get_node_or_null("Control")
		if control:
			control.visible = game_paused
	
	print("Estado de pausa: ", game_paused)

# Reinicia a cena atual
func reiniciar_cena() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

# Volta para o menu principal mantendo a gameplay pausada em segundo plano
func voltar_menu_principal() -> void:
	print("Mostrando menu principal e mantendo gameplay pausada...")
	
	# Mantém o jogo pausado
	get_tree().paused = true
	
	# Obtém a cena do menu principal
	var menu_principal = load("res://scenes/main menu/MenuPrincipal.tscn").instantiate()
	
	# Adiciona o menu por cima da gameplay atual usando uma nova CanvasLayer
	var menu_layer = CanvasLayer.new()
	menu_layer.name = "MenuPrincipalLayer"
	menu_layer.process_mode = Node.PROCESS_MODE_ALWAYS  # Permite interagir mesmo com o jogo pausado
	
	menu_layer.add_child(menu_principal)
	add_child(menu_layer)
	
	# Guarda a referência para poder voltar à gameplay facilmente
	if not get_tree().get_root().has_meta("gameplay_scene"):
		get_tree().get_root().set_meta("gameplay_scene", self)
		print("Referência para gameplay guardada com sucesso")

# Sai do jogo
func sair_jogo() -> void:
	# Primeiro verificamos se existe um sistema de orquestração
	var orquestrador = get_node_or_null("/root/Game/Orquestrador")
	var game_node = get_node_or_null("/root/Game")
	
	if game_node and game_node.has_method("quit_game"):
		# Se existe um Game com método quit_game, usamos ele
		print("Saindo do jogo via Game controller...")
		game_node.quit_game()
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
	
	# Verificar se temos o nó de configurações já referenciado
	if config and config.visible == false:
		config.visible = true
		print("Exibindo nó de configurações existente")
		return
	
	# Caso não tenhamos o nó, tentamos carregar a cena
	var config_scene = "res://scenes/configurações/config.tscn"
	if ResourceLoader.exists(config_scene):
		# Pausar o jogo enquanto estamos nas configurações
		get_tree().paused = true
		
		# Carregar a cena de configurações
		var config_instance = load(config_scene).instantiate()
		
		# Adicionar sinal para fechar
		if config_instance.has_signal("closed"):
			config_instance.closed.connect(func(): get_tree().paused = game_paused)
		
		# Adicionar à árvore
		add_child(config_instance)
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
	toggle_pause()  # Fecha o menu de pausa e retoma o jogo

func _on_config_pressed() -> void:
	print("Botão Config pressionado")
	abrir_configuracoes()

func _on_voltar_menu_pressed() -> void:
	print("Botão Menu Principal pressionado")
	voltar_menu_principal()

func _on_sair_pause_pressed() -> void:
	print("Botão Sair pressionado")
	sair_jogo()

# Função auxiliar para esconder o menu de pausa
func _hide_pause_menu() -> void:
	if menu_pausa:
		menu_pausa.visible = false
		
		# Se o menu de pausa tem um nó Control, atualizar sua visibilidade
		var control = menu_pausa.get_node_or_null("Control")
		if control:
			control.visible = false
			
	# Atualiza o estado do jogo
	game_paused = false
	print("Menu de pausa escondido")

# Função para garantir que todos os elementos de UI estejam em CanvasLayers
func _ensure_ui_in_canvas_layer() -> void:
	# Lista de elementos da UI para verificar
	var ui_elements = {
		"menu_pausa": menu_pausa,
		"transition_screen": transition_screen,
		"loading_screen": loading_screen,
		"dialogue_box": dialogue_box,
		"description_box": description_box
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
