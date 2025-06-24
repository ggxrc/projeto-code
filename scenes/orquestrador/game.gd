extends Node

# Sinal para notificar quando o estado do jogo muda
signal game_state_changed(new_state)

# Referências para as cenas principais
@onready var menu_principal: Node = $MenuPrincipal
@onready var prologue: Node = $Prologue
@onready var menu_opcoes: Node = $MenuOpcoes
# Nota: gameplay não é mais um nó filho - será carregado via change_scene_to_file
@onready var menu_pausa = $Effects/MenuPausa
@onready var config: CanvasLayer = $Config/CanvasLayer

# Referências para os nodes autoload
@onready var loading_screen = $Effects/LoadingScreen

# Flag para controlar se o prólogo já foi concluído - resetada para false no início de cada sessão
var prologo_introducao_concluida: bool = false

var scenes: Array[Node]
var current_scene: Node
var is_transitioning: bool = false

enum GameState {
	NONE,
	MENU,
	PROLOGUE,
	PLAYING,
	PAUSED,
	OPTIONS,
	CONFIG_FROM_PAUSE
}
var current_state: GameState = GameState.MENU
var previous_state_before_pause: GameState = GameState.NONE
var previous_state_before_options_pause: GameState = GameState.NONE

func _ready() -> void:
	#get_tree().paused = true
	
	# IMPORTANTE: Garantir que a flag do prólogo começa como false em cada nova sessão
	# Isso faz com que o diálogo seja exibido pelo menos uma vez ao jogador
	prologo_introducao_concluida = false
	print("Game: Flag 'prologo_introducao_concluida' inicializada como false.")
	
	# Verificar se o AudioManager está disponível como autoload
	if AudioManager:
		print("Game: AudioManager encontrado como autoload.")
		# Conectar ao sinal de mudança de estado para gerenciar músicas
		if not game_state_changed.is_connected(_on_game_state_changed):
			game_state_changed.connect(_on_game_state_changed)
	
	_setup_scenes_array()
	_initialize_game_state_and_scenes()
	_connect_all_scene_signals()
	_verify_autoload_nodes()
	
	# Log de depuração para confirmar o estado
	print_debug_info()

func _verify_autoload_nodes() -> void:
	# Verifica se os AutoLoad estão funcionando corretamente
	if not TransitionScreen:
		push_error("TransitionScreen não está disponível como AutoLoad!")
	
	# Verifica o LoadingScreen (que é um nó local, não um AutoLoad)
	if not loading_screen:
		loading_screen = $Effects/LoadingScreen
		
	if not loading_screen:
		push_error("LoadingScreen não encontrado como nó filho em $Effects!")
	else:
		# Verifique se o script está correto, tentando acessar uma propriedade
		if not loading_screen.has_method("start_loading"):
			push_error("LoadingScreen não tem o método start_loading!")
		else:
			print("LoadingScreen encontrado e configurado corretamente.")

func _setup_scenes_array() -> void:
	scenes = [
		menu_principal,
		prologue,
		menu_opcoes
	]
	scenes = scenes.filter(func(scene: Node) -> bool: return scene != null)

func _initialize_game_state_and_scenes() -> void:
	_deactivate_all_main_scenes()

	if menu_pausa:
		menu_pausa.visible = false
		menu_pausa.process_mode = Node.PROCESS_MODE_DISABLED
	
	if config:
		config.visible = false
		config.process_mode = Node.PROCESS_MODE_DISABLED
	
	_activate_scene(menu_principal, GameState.MENU)

func _connect_all_scene_signals() -> void:
	_connect_menu_principal_signals()
	_connect_prologue_signals()
	_connect_menu_pausa_signals()
	_connect_config_signals()

func _connect_menu_principal_signals() -> void:
	if not menu_principal: return

	var iniciar_btn: Button = menu_principal.get_node_or_null("IniciarButton")
	var opcoes_btn: Button = menu_principal.get_node_or_null("OpcoesButton")
	var sair_btn: Button = menu_principal.get_node_or_null("SairButton")
	
	if iniciar_btn and not iniciar_btn.pressed.is_connected(_on_iniciar_pressed):
		iniciar_btn.pressed.connect(_on_iniciar_pressed)
	if opcoes_btn and not opcoes_btn.pressed.is_connected(_on_opcoes_pressed):
		opcoes_btn.pressed.connect(_on_opcoes_pressed)
	if sair_btn and not sair_btn.pressed.is_connected(_on_sair_pressed):
		sair_btn.pressed.connect(_on_sair_pressed)

func _connect_prologue_signals() -> void:
	if not prologue: return

	var voltar_btn: Button = prologue.get_node_or_null("VoltarButton")
	var pular_btn: Button = prologue.get_node_or_null("PularButton")
	
	if voltar_btn and not voltar_btn.pressed.is_connected(_on_voltar_menu_pressed):
		voltar_btn.pressed.connect(_on_voltar_menu_pressed)
	if pular_btn and not pular_btn.pressed.is_connected(_on_pular_prologue_pressed):
		pular_btn.pressed.connect(_on_pular_prologue_pressed)

func _connect_menu_pausa_signals() -> void:
	if not menu_pausa: return

	var retomar_btn: Button = menu_pausa.get_node_or_null("Retomar")
	var config_btn: Button = menu_pausa.get_node_or_null("Config") 
	var voltar_menu_btn: Button = menu_pausa.get_node_or_null("VoltarMenu")
	var sair_jogo_btn: Button = menu_pausa.get_node_or_null("SairJogoButton")

	if retomar_btn and not retomar_btn.pressed.is_connected(_on_retomar_pressed):
		retomar_btn.pressed.connect(_on_retomar_pressed)
	if config_btn and not config_btn.pressed.is_connected(_on_config_pressed):
		config_btn.pressed.connect(_on_config_pressed)
	if voltar_menu_btn and not voltar_menu_btn.pressed.is_connected(_on_voltar_menu_from_pause_pressed):
		voltar_menu_btn.pressed.connect(_on_voltar_menu_from_pause_pressed)
	if sair_jogo_btn and not sair_jogo_btn.pressed.is_connected(_on_sair_pause_pressed):
		sair_jogo_btn.pressed.connect(_on_sair_pause_pressed)

func _connect_config_signals() -> void:
	if not config: return
	var voltar_config_btn: Button = config.get_node_or_null("VoltarConfigButton") 
	if voltar_config_btn and not voltar_config_btn.pressed.is_connected(_on_voltar_from_config_pressed):
		voltar_config_btn.pressed.connect(_on_voltar_from_config_pressed)

func _deactivate_all_main_scenes() -> void:
	for scene in scenes:
		if scene:
			scene.visible = false
			scene.process_mode = Node.PROCESS_MODE_DISABLED
			if scene.has_method("set_process_input"):
				scene.set_process_input(false)
			if scene.has_method("set_process_unhandled_input"):
				scene.set_process_unhandled_input(false)

func _activate_scene(scene_node: Node, target_state: GameState) -> void:
	if not scene_node or (scene_node == current_scene and current_state == target_state and not is_transitioning):
		if scene_node == current_scene and current_state != target_state:
			pass
		elif scene_node == current_scene and current_state == target_state:
			return

	if get_tree().paused:
		get_tree().paused = false
	
	if menu_pausa and menu_pausa.visible:
		menu_pausa.visible = false
		menu_pausa.process_mode = Node.PROCESS_MODE_DISABLED
	if config and config.visible:
		config.visible = false
		config.process_mode = Node.PROCESS_MODE_DISABLED
	
	if current_scene and current_scene != scene_node:
		current_scene.visible = false
		current_scene.process_mode = Node.PROCESS_MODE_DISABLED
		if current_scene.has_method("set_process_input"):
			current_scene.set_process_input(false)
		if current_scene.has_method("set_process_unhandled_input"):
			current_scene.set_process_unhandled_input(false)
		if current_scene.has_method("_on_scene_deactivating"):
			current_scene._on_scene_deactivating()

	scene_node.visible = true
	scene_node.process_mode = Node.PROCESS_MODE_INHERIT
	if scene_node.has_method("set_process_input"):
		scene_node.set_process_input(true)
	if scene_node.has_method("set_process_unhandled_input"):
		scene_node.set_process_unhandled_input(true)
	
	if scene_node.has_method("_on_scene_activated"):
		scene_node._on_scene_activated()
	
	current_scene = scene_node
	var old_state = current_state
	current_state = target_state
	
	print("Cena ativada: ", scene_node.name, " | Estado: ", GameState.keys()[target_state])
	
	# Emite o sinal de mudança de estado se o estado realmente mudou
	if old_state != current_state:
		emit_signal("game_state_changed", current_state)
		print("Game: Emitido sinal de mudança de estado para: ", GameState.keys()[current_state])

func switch_to_scene(next_scene_node: Node, next_game_state: GameState, transition_effect_type: String = "loading") -> void:
	if is_transitioning or (next_scene_node == current_scene and current_state == next_game_state):
		return
	
	is_transitioning = true
	
	if get_tree().paused:
		get_tree().paused = false
	if menu_pausa and menu_pausa.visible:
		menu_pausa.visible = false
		menu_pausa.process_mode = Node.PROCESS_MODE_DISABLED
	if config and config.visible:
		config.visible = false
		config.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Preparar transição de áudio se necessário
	if Engine.has_singleton("AudioManager") and current_state != next_game_state:
		var audio_manager = Engine.get_singleton("AudioManager")
		
		# Inicia fade out da música atual para uma transição suave
		if current_state != GameState.PAUSED and current_state != GameState.CONFIG_FROM_PAUSE:
			audio_manager.stop_music(1.0)
	
	# Usa loading screen para todas as transições exceto 'instant'
	if transition_effect_type == "instant":
		_perform_instant_transition(next_scene_node, next_game_state)
	else:
		await _perform_loading_transition(next_scene_node, next_game_state)
	
	is_transitioning = false

func _perform_fade_transition(next_scene: Node, next_state: GameState, duration: float = -1.0) -> void:
	if current_scene and current_scene.has_method("_on_scene_deactivating"):
		current_scene._on_scene_deactivating()
	
	if TransitionScreen.has_method("fade_out"):
		if duration > 0:
			await TransitionScreen.fade_out(duration)
		else:
			await TransitionScreen.fade_out()
	
	_deactivate_all_main_scenes()
	_activate_scene(next_scene, next_state)
	
	if TransitionScreen.has_method("fade_in"):
		if duration > 0:
			await TransitionScreen.fade_in(duration)
		else:
			await TransitionScreen.fade_in()

func _perform_loading_transition(next_scene: Node, next_state: GameState) -> void:
	if current_scene and current_scene.has_method("_on_scene_deactivating"):
		current_scene._on_scene_deactivating()
	
	# Fade out com TransitionScreen
	if TransitionScreen and TransitionScreen.has_method("fade_out"):
		await TransitionScreen.fade_out()
	
	_deactivate_all_main_scenes()
	
	# Verificar loading_screen
	if not loading_screen:
		# Tenta obter diretamente como nó filho
		loading_screen = $Effects/LoadingScreen
	
	# Mostrar tela de loading
	if loading_screen:
		print("LoadingScreen encontrado, iniciando...")
		loading_screen.start_loading(false) # Sem transições internas
		await loading_screen.loading_finished
	else:
		print("ERRO: LoadingScreen não encontrado!")
	
	_activate_scene(next_scene, next_state)
	
	# Fade in para revelar a cena
	if TransitionScreen and TransitionScreen.has_method("fade_in"):
		await TransitionScreen.fade_in()

func _perform_instant_transition(next_scene: Node, next_state: GameState) -> void:
	if current_scene and current_scene.has_method("_on_scene_deactivating"):
		current_scene._on_scene_deactivating()
	_deactivate_all_main_scenes()
	_activate_scene(next_scene, next_state)

func navigate_to_main_menu(transition_effect: String = "loading") -> void:
	# Limpar instância de gameplay se existir ao voltar para o menu
	_cleanup_gameplay_instance()
	
	if menu_principal:
		switch_to_scene(menu_principal, GameState.MENU, transition_effect)
	else:
		printerr("Tentativa de ir para Menu Principal, mas a cena não está definida.")

func navigate_to_prologue(transition_effect: String = "loading") -> void:
	if prologue:
		switch_to_scene(prologue, GameState.PROLOGUE, transition_effect)
	else:
		printerr("Tentativa de ir para Prólogo, mas a cena não está definida.")

func navigate_to_gameplay(_transition_effect: String = "loading") -> void:
	# A gameplay agora é carregada como uma subcena do Game
	# para preservar os sistemas e hierarquia, mas sendo a cena principal ativa
	print("Carregando gameplay como subcena do Game")
	
	if is_transitioning:
		print("Transição já em andamento, ignorando solicitação")
		return
	
	is_transitioning = true
	
	# Preparar transição de áudio
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		audio_manager.stop_music(1.0)
	
	# Fazer transição visual se disponível
	if TransitionScreen and TransitionScreen.has_method("fade_out"):
		await TransitionScreen.fade_out()
	
	# Limpar instância anterior de gameplay se existir
	_cleanup_gameplay_instance()
	
	# Desativar todas as cenas principais
	_deactivate_all_main_scenes()
	
	# Carregar e instanciar a cena de gameplay
	var gameplay_scene = load("res://scenes/prologue/Meio/Gameplay.tscn")
	if gameplay_scene:
		var gameplay_instance = gameplay_scene.instantiate()
		gameplay_instance.name = "Gameplay"
		
		# Adicionar como filho do Game
		add_child(gameplay_instance)
		
		# Atualizar referências
		current_scene = gameplay_instance
		current_state = GameState.PLAYING
		
		print("Gameplay carregada como subcena do Game")
		
		# Emitir sinal de mudança de estado
		emit_signal("game_state_changed", current_state)
		
		# Fazer transição visual de entrada
		if TransitionScreen and TransitionScreen.has_method("fade_in"):
			await TransitionScreen.fade_in()
	else:
		printerr("Falha ao carregar a cena de Gameplay!")
	
	is_transitioning = false

func navigate_to_options_from_main_menu(transition_effect: String = "loading") -> void:
	if menu_opcoes:
		switch_to_scene(menu_opcoes, GameState.OPTIONS, transition_effect) # Usa GameState.OPTIONS
	else:
		printerr("Tentativa de abrir Opções (Menu Principal), mas a cena não está definida.")

func trigger_quit_game() -> void:
	if TransitionScreen.has_method("fade_out"):
		await TransitionScreen.fade_out()
	get_tree().quit()

func get_current_active_scene_name() -> String:
	if current_scene:
		return current_scene.name
	return "Nenhuma"

func get_current_game_state() -> GameState:
	return current_state

func is_game_in_state(state_to_check: GameState) -> bool:
	return current_state == state_to_check

func print_debug_info() -> void:
	print("=== INFORMAÇÕES DE DEBUG DO JOGO ===")
	print("Cena Atual: ", get_current_active_scene_name())
	print("Estado Atual: ", GameState.keys()[current_state] if current_state != GameState.NONE else "NONE")
	print("Em Transição: ", is_transitioning)
	print("Engine Pausada: ", get_tree().paused)
	if menu_pausa:
		print("Menu Pausa Visível: ", menu_pausa.visible)
	if config:
		print("Config Visível: ", config.visible)
	print("====================================")

func _on_iniciar_pressed() -> void:
	print("Botão 'Iniciar' pressionado")
	start_prologue()

func _on_opcoes_pressed() -> void:
	navigate_to_options_from_main_menu()

func _on_sair_pressed() -> void:
	trigger_quit_game()

func _on_voltar_menu_pressed() -> void:
	navigate_to_main_menu("loading")

func _on_pular_prologue_pressed() -> void:
	navigate_to_gameplay()

func _on_pause_button_pressed() -> void:
	if not menu_pausa:
		printerr("Menu de Pausa não encontrado!")
		return

	if current_state == GameState.PLAYING or current_state == GameState.PROLOGUE:
		if current_state != GameState.NONE:
			previous_state_before_pause = current_state
		else:
			previous_state_before_pause = GameState.PLAYING
		
		get_tree().paused = true
		
		menu_pausa.visible = true
		menu_pausa.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		
		var old_state = current_state
		current_state = GameState.PAUSED
		print("Jogo Pausado. Menu de Pausa ativado.")
		
		# Emite o sinal de mudança de estado
		if old_state != current_state:
			emit_signal("game_state_changed", current_state)
			print("Game: Emitido sinal de mudança de estado para: ", GameState.keys()[current_state])
		
		if menu_pausa.has_method("_on_scene_activated"):
			menu_pausa._on_scene_activated()

	elif current_state == GameState.PAUSED:
		_on_retomar_pressed()

func _on_retomar_pressed() -> void:
	print("Game: Método _on_retomar_pressed chamado")
	
	# Proteção contra tentativa de retomar um jogo que não está pausado
	if not get_tree():
		print("ERRO: get_tree() retornou nulo em _on_retomar_pressed no Game. Abortando...")
		return
		
	# Verifica se realmente estamos no estado pausado e temos o menu
	if not menu_pausa:
		print("AVISO: menu_pausa não encontrado em _on_retomar_pressed no Game")
		# Continua mesmo sem o menu para garantir que o jogo seja despausado
	else:
		if not get_tree().paused:
			print("AVISO: O jogo já não está pausado em _on_retomar_pressed no Game")
	
	# Força despausar o jogo
	get_tree().paused = false
	
	# Se temos o menu de pausa, atualizamos sua visibilidade
	if menu_pausa and is_instance_valid(menu_pausa):
		menu_pausa.visible = false
		menu_pausa.process_mode = Node.PROCESS_MODE_DISABLED
		print("Game: Menu de pausa escondido com sucesso")
	
	var old_state = current_state
	
	if previous_state_before_pause != GameState.NONE:
		current_state = previous_state_before_pause
		previous_state_before_pause = GameState.NONE
	else:
		current_state = GameState.PLAYING
	
	print("Game: Jogo Retomado. Estado: ", GameState.keys()[current_state])
	
	# Emite o sinal de mudança de estado
	if old_state != current_state:
		emit_signal("game_state_changed", current_state)
		print("Game: Emitido sinal de mudança de estado para: ", GameState.keys()[current_state])
	
	# Chama o método de desativação do menu de pausa com segurança
	if menu_pausa and is_instance_valid(menu_pausa) and menu_pausa.has_method("_on_scene_deactivating"):
		menu_pausa._on_scene_deactivating()

func _on_config_pressed() -> void:
	if not config or not menu_pausa:
		printerr("Cena de Configuração ou Menu de Pausa não encontrado!")
		return

	if current_state == GameState.PAUSED:
		previous_state_before_options_pause = GameState.PAUSED 
		
		menu_pausa.visible = false

		config.visible = true
		config.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		
		var old_state = current_state
		current_state = GameState.CONFIG_FROM_PAUSE 
		print("Menu de Configuração (via Pausa) ativado.")
		
		# Emite o sinal de mudança de estado
		if old_state != current_state:
			emit_signal("game_state_changed", current_state)
			print("Game: Emitido sinal de mudança de estado para: ", GameState.keys()[current_state])
		
		if config.has_method("_on_scene_activated"):
			config._on_scene_activated()

func _on_voltar_menu_from_pause_pressed() -> void:
	if get_tree().paused:
		get_tree().paused = false
	
	if menu_pausa and menu_pausa.visible:
		menu_pausa.visible = false
		menu_pausa.process_mode = Node.PROCESS_MODE_DISABLED
	if config and config.visible:
		config.visible = false
		config.process_mode = Node.PROCESS_MODE_DISABLED

	navigate_to_main_menu("loading")

func _on_sair_pause_pressed() -> void:
	if get_tree().paused:
		get_tree().paused = false
	
	if menu_pausa and menu_pausa.visible:
		menu_pausa.visible = false
	if config and config.visible:
		config.visible = false

	if TransitionScreen.has_method("fade_out"):
		await TransitionScreen.fade_out(1.5)
	get_tree().quit()

func _on_voltar_from_config_pressed() -> void:
	if not config or not menu_pausa:
		printerr("Cena de Configuração ou Menu de Pausa não encontrado!")
		return

	if current_state == GameState.CONFIG_FROM_PAUSE:
		config.visible = false
		config.process_mode = Node.PROCESS_MODE_DISABLED
		if config.has_method("_on_scene_deactivating"):
			config._on_scene_deactivating()

		menu_pausa.visible = true 
		menu_pausa.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		
		var old_state = current_state
		current_state = GameState.PAUSED 
		print("Retornou para o Menu de Pausa.")
		
		# Emite o sinal de mudança de estado
		if old_state != current_state:
			emit_signal("game_state_changed", current_state)
			print("Game: Emitido sinal de mudança de estado para: ", GameState.keys()[current_state])
		
		if menu_pausa.has_method("_on_scene_activated"):
			menu_pausa._on_scene_activated()

func start_prologue() -> void:
	# O prólogo.gd verifica esta flag e pula diretamente para o gameplay 
	# se o jogador já completou o prólogo anteriormente
	print("Game: Iniciando prólogo. Flag 'prologo_introducao_concluida' = ", prologo_introducao_concluida)
	navigate_to_prologue()

# Função para carregar uma cena por caminho de arquivo
func load_scene_by_path(scene_path: String, transition_effect: String = "loading") -> void:
	print("Game: Carregando cena por caminho: ", scene_path)
	
	if scene_path.is_empty():
		printerr("Game: Tentativa de carregar cena com caminho vazio!")
		return
	
	# Verifica se a cena existe antes de tentar carregá-la
	if not ResourceLoader.exists(scene_path):
		printerr("Game: Cena não encontrada no caminho: ", scene_path)
		return
		
	# Determina o estado do jogo com base no caminho da cena
	var target_state = GameState.PLAYING  # Estado padrão
	
	if "prologue" in scene_path.to_lower():
		target_state = GameState.PROLOGUE
	elif "menu" in scene_path.to_lower():
		target_state = GameState.MENU
	
	# Inicia a transição
	is_transitioning = true
	
	# Usa loading screen para todas as transições exceto 'instant'
	if transition_effect == "instant":
		_deactivate_all_main_scenes()
		
		# Carrega e instancia a nova cena
		var scene_resource = load(scene_path)
		var new_scene = scene_resource.instantiate()
		
		# Adiciona ao cenário e ativa
		add_child(new_scene)
		current_scene = new_scene
		current_state = target_state
		
		is_transitioning = false
	else:
		# Fade out
		if TransitionScreen and TransitionScreen.has_method("fade_out"):
			await TransitionScreen.fade_out()
		
		_deactivate_all_main_scenes()
		
		# Verificar loading_screen
		if not loading_screen:
			loading_screen = $Effects/LoadingScreen
		
		# Mostrar tela de loading
		if loading_screen:
			loading_screen.start_loading(false) # Sem transições internas
			await loading_screen.loading_finished
		
		# Carrega e instancia a nova cena
		var scene_resource = load(scene_path)
		var new_scene = scene_resource.instantiate()
		
		# Adiciona ao cenário e ativa
		add_child(new_scene)
		current_scene = new_scene
		current_state = target_state
		
		# Fade in para revelar a cena
		if TransitionScreen and TransitionScreen.has_method("fade_in"):
			await TransitionScreen.fade_in()
			
		is_transitioning = false
		
	# Emite o sinal de mudança de estado
	emit_signal("game_state_changed", current_state)
	print("Game: Cena carregada com sucesso: ", scene_path)

func test_loading_screen() -> void:
	# Este método apenas demonstra o uso da tela de loading
	if not loading_screen:
		# Tenta obter diretamente do caminho de nó filho
		loading_screen = $Effects/LoadingScreen
		
	if loading_screen:
		print("Iniciando teste da tela de loading...")
		loading_screen.start_loading()
		await loading_screen.loading_finished
		print("Loading concluído!")
	else:
		print("LoadingScreen não encontrado!")

func _on_game_state_changed(new_state: GameState) -> void:
	# Lógica para gerenciar músicas entre estados do jogo
	print("Mudança de estado do jogo detectada: ", GameState.keys()[new_state])
	
	# O AudioManager está disponível globalmente como um autoload
	match new_state:
		GameState.MENU:
			# Toca música do menu
			AudioManager.play_music("menu", 1.0)
		GameState.PROLOGUE:
			# Toca música do prólogo
			AudioManager.play_music("prologue", 1.5)
		GameState.PLAYING:
			# Toca música da gameplay
			AudioManager.play_music("gameplay", 1.5)
		GameState.PAUSED:
			# Não mudamos a música no estado pausado, apenas deixamos tocando
			pass
		GameState.OPTIONS, GameState.CONFIG_FROM_PAUSE:
			# Não mudamos a música no estado de opções, apenas deixamos tocando
			pass
		_:
			# Para qualquer outro estado, para a música
			AudioManager.stop_music(1.0)

# ============ CONFIGURAÇÕES ============

func close_options() -> void:
	# Função chamada quando o botão voltar é pressionado na tela de configurações
	print("Game: Fechando tela de opções")
	if config:
		config.visible = false
		config.process_mode = Node.PROCESS_MODE_DISABLED
		
		# Voltar ao estado anterior
		var old_state = current_state
		current_state = GameState.MENU
		print("Retornou para o Menu Principal.")
		
		# Emite o sinal de mudança de estado
		if old_state != current_state:
			emit_signal("game_state_changed", current_state)
			print("Game: Emitido sinal de mudança de estado para: ", GameState.keys()[current_state])
		
		if menu_principal and menu_principal.visible == false:
			menu_principal.visible = true
			menu_principal.process_mode = Node.PROCESS_MODE_INHERIT
			if menu_principal.has_method("_on_scene_activated"):
				menu_principal._on_scene_activated()

func close_options_from_pause() -> void:
	# Função chamada quando o botão voltar é pressionado na tela de configurações durante pausa
	print("Game: Fechando tela de opções (a partir da pausa)")
	if config:
		config.visible = false
		config.process_mode = Node.PROCESS_MODE_DISABLED
		
		# Restaurar menu de pausa
		if menu_pausa:
			menu_pausa.visible = true
			menu_pausa.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
			if menu_pausa.has_method("_on_scene_activated"):
				menu_pausa._on_scene_activated()
		
		# Voltar ao estado de pausa
		var old_state = current_state
		current_state = GameState.PAUSED
		print("Retornou para o Menu de Pausa.")
		
		# Emite o sinal de mudança de estado
		if old_state != current_state:
			emit_signal("game_state_changed", current_state)
			print("Game: Emitido sinal de mudança de estado para: ", GameState.keys()[current_state])

# Método para continuar o jogo de onde parou após voltar do menu principal
func continue_game() -> void:
	print("Game: Continuando jogo da última sessão...")
	
	# Carregar a gameplay como subcena
	navigate_to_gameplay("loading")

# Método para ir ao menu principal a partir de qualquer cena, preservando o estado da gameplay
func go_to_menu() -> void:
	print("Game: Voltando ao menu principal, preservando estado da gameplay...")
	
	# Se estamos na gameplay, salvamos o estado atual
	if current_state == GameState.PLAYING:
		previous_state_before_pause = GameState.PLAYING
		print("Game: Estado da gameplay salvo para futura continuação")
	
	# Despausa o jogo antes de trocar de cena
	get_tree().paused = false
	
	# Ativa o menu principal
	_deactivate_all_main_scenes()
	_activate_scene(menu_principal, GameState.MENU)
	
	# Inicia a música do menu
	if AudioManager:
		AudioManager.play_music("menu", 1.0)
	
	# Se houver uma tela de transição, usamos ela
	if TransitionScreen:
		await TransitionScreen.fade_in()

# Função para retomar o jogo (chamada pelo menu de pausa)
func resume_game() -> void:
	print("Game: resume_game() chamado - redirecionando para _on_retomar_pressed")
	_on_retomar_pressed()

# Método para limpar a instância de gameplay quando necessário
func _cleanup_gameplay_instance() -> void:
	var gameplay_instance = get_node_or_null("Gameplay")
	if gameplay_instance:
		print("Removendo instância anterior de gameplay")
		gameplay_instance.queue_free()
		
		# Se era a cena atual, resetar referência
		if current_scene == gameplay_instance:
			current_scene = null
