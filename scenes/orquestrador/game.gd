extends Node

# Referências para as cenas principais
@onready var menu_principal: Node = $MenuPrincipal
@onready var prologue: Node = $Prologue
@onready var gameplay: Node = $Gameplay
@onready var menu_opcoes: Node = $MenuOpcoes
@onready var menu_pausa = $Effects/MenuPausa
@onready var config: CanvasLayer = $Config/CanvasLayer

# Referências para os nodes autoload
@onready var loading_screen = $Effects/LoadingScreen

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
	_setup_scenes_array()
	_initialize_game_state_and_scenes()
	_connect_all_scene_signals()
	_verify_autoload_nodes()

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
		gameplay,
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
	current_state = target_state
	
	print("Cena ativada: ", scene_node.name, " | Estado: ", GameState.keys()[target_state])

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
	
	# Fade in para revelar a cena
	if TransitionScreen.has_method("fade_in"):
		await TransitionScreen.fade_in()

func _perform_instant_transition(next_scene: Node, next_state: GameState) -> void:
	if current_scene and current_scene.has_method("_on_scene_deactivating"):
		current_scene._on_scene_deactivating()
	_deactivate_all_main_scenes()
	_activate_scene(next_scene, next_state)

func navigate_to_main_menu(transition_effect: String = "loading") -> void:
	if menu_principal:
		switch_to_scene(menu_principal, GameState.MENU, transition_effect)
	else:
		printerr("Tentativa de ir para Menu Principal, mas a cena não está definida.")

func navigate_to_prologue(transition_effect: String = "loading") -> void:
	if prologue:
		switch_to_scene(prologue, GameState.PROLOGUE, transition_effect)
	else:
		printerr("Tentativa de ir para Prólogo, mas a cena não está definida.")

func navigate_to_gameplay(transition_effect: String = "loading") -> void:
	if gameplay:
		switch_to_scene(gameplay, GameState.PLAYING, transition_effect)
	else:
		printerr("Tentativa de iniciar Gameplay, mas a cena não está definida.")

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
	navigate_to_main_menu("fade")

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
		
		current_state = GameState.PAUSED
		print("Jogo Pausado. Menu de Pausa ativado.")
		
		if menu_pausa.has_method("_on_scene_activated"):
			menu_pausa._on_scene_activated()

	elif current_state == GameState.PAUSED:
		_on_retomar_pressed()

func _on_retomar_pressed() -> void:
	if not menu_pausa or not get_tree().paused:
		return

	get_tree().paused = false
	
	menu_pausa.visible = false
	menu_pausa.process_mode = Node.PROCESS_MODE_DISABLED
	
	if previous_state_before_pause != GameState.NONE:
		current_state = previous_state_before_pause
		previous_state_before_pause = GameState.NONE
	else:
		current_state = GameState.PLAYING
	
	print("Jogo Retomado. Estado: ", GameState.keys()[current_state])
	
	if menu_pausa.has_method("_on_scene_deactivating"):
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
		
		current_state = GameState.CONFIG_FROM_PAUSE 
		print("Menu de Configuração (via Pausa) ativado.")
		
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

	navigate_to_main_menu("fade")

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
		
		current_state = GameState.PAUSED 
		print("Retornou para o Menu de Pausa.")
		
		if menu_pausa.has_method("_on_scene_activated"):
			menu_pausa._on_scene_activated()

func start_prologue() -> void:
	navigate_to_prologue()

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
