# Game.gd - Node principal que contém todas as cenas
extends Node

# Referencias para as cenas filhas
@onready var menu_principal = $MenuPrincipal
@onready var prologue = $Prologue
@onready var menu_opcoes = $MenuOpcoes  # se tiver
@onready var gameplay = $Gameplay      # se tiver
# Adicione outras cenas conforme necessário

var scenes: Array[Node]
var current_scene: Node
var is_transitioning: bool = false

# Sistema de estados para melhor controle
enum GameState {
	MENU,
	PROLOGUE,
	PLAYING,
	PAUSED,
	OPTIONS
}

var current_state: GameState = GameState.MENU

func _ready() -> void:
	_setup_scenes()
	_setup_initial_state()
	_connect_scene_signals()

# ============ CONFIGURAÇÃO INICIAL ============

func _setup_scenes() -> void:
	scenes = [
		menu_principal,
		prologue,
		# Adicione outras cenas aqui
	]
	
	# Remove cenas nulas (caso alguma não exista)
	scenes = scenes.filter(func(scene): return scene != null)

func _setup_initial_state() -> void:
	_deactivate_all_scenes()
	_activate_scene(menu_principal, GameState.MENU)

func _connect_scene_signals() -> void:
	# Conecta sinais dos botões de cada cena
	_connect_menu_signals()
	_connect_prologue_signals()
	# Adicione outras conexões conforme necessário

func _connect_menu_signals() -> void:
	if menu_principal:
		# Conecta botões do menu principal
		var iniciar_btn = menu_principal.get_node_or_null("IniciarButton")
		var opcoes_btn = menu_principal.get_node_or_null("OpcoesButton")
		var sair_btn = menu_principal.get_node_or_null("SairButton")
		
		if iniciar_btn and not iniciar_btn.pressed.is_connected(_on_iniciar_pressed):
			iniciar_btn.pressed.connect(_on_iniciar_pressed)
		if opcoes_btn and not opcoes_btn.pressed.is_connected(_on_opcoes_pressed):
			opcoes_btn.pressed.connect(_on_opcoes_pressed)
		if sair_btn and not sair_btn.pressed.is_connected(_on_sair_pressed):
			sair_btn.pressed.connect(_on_sair_pressed)

func _connect_prologue_signals() -> void:
	if prologue:
		var voltar_btn = prologue.get_node_or_null("VoltarButton")
		var pular_btn = prologue.get_node_or_null("PularButton")
		
		if voltar_btn and not voltar_btn.pressed.is_connected(_on_voltar_menu_pressed):
			voltar_btn.pressed.connect(_on_voltar_menu_pressed)
		if pular_btn and not pular_btn.pressed.is_connected(_on_pular_prologue_pressed):
			pular_btn.pressed.connect(_on_pular_prologue_pressed)

# ============ SISTEMA DE CENAS ============

func _deactivate_all_scenes() -> void:
	for scene in scenes:
		if scene:
			scene.visible = false
			scene.process_mode = Node.PROCESS_MODE_DISABLED
			
			# Desativa input para evitar bugs de toque
			if scene.has_method("set_process_input"):
				scene.set_process_input(false)
			if scene.has_method("set_process_unhandled_input"):
				scene.set_process_unhandled_input(false)

func _activate_scene(scene: Node, state: GameState) -> void:
	if not scene or scene == current_scene:
		return
	
	scene.visible = true
	scene.process_mode = Node.PROCESS_MODE_INHERIT
	
	# Reativa input
	if scene.has_method("set_process_input"):
		scene.set_process_input(true)
	if scene.has_method("set_process_unhandled_input"):
		scene.set_process_unhandled_input(true)
	
	# Chama método de ativação se existir na cena
	if scene.has_method("_on_scene_activated"):
		scene._on_scene_activated()
	
	current_scene = scene
	current_state = state
	
	print("Cena ativada: ", scene.name, " | Estado: ", GameState.keys()[state])

# ============ TRANSIÇÕES ============

func change_scene_with_transition(next_scene: Node, next_state: GameState, transition_type: String = "fade") -> void:
	if is_transitioning or next_scene == current_scene:
		return
	
	is_transitioning = true
	
	match transition_type:
		"fade":
			await _transition_with_fade(next_scene, next_state)
		"quick_fade":
			await _transition_with_fade(next_scene, next_state, 0.2)
		"slow_fade":
			await _transition_with_fade(next_scene, next_state, 1.0)
		"instant":
			_instant_transition(next_scene, next_state)
		_:
			await _transition_with_fade(next_scene, next_state)
	
	is_transitioning = false

func _transition_with_fade(next_scene: Node, next_state: GameState, duration: float = -1) -> void:
	# Chama método antes da transição se existir na cena atual
	if current_scene and current_scene.has_method("_on_scene_deactivating"):
		current_scene._on_scene_deactivating()
	
	# Fade out usando TransitionScreen
	if duration > 0:
		await TransitionScreen.fade_out(duration)
	else:
		await TransitionScreen.fade_out()
	
	# Troca cena
	_deactivate_all_scenes()
	_activate_scene(next_scene, next_state)
	
	# Fade in
	if duration > 0:
		await TransitionScreen.fade_in(duration)
	else:
		await TransitionScreen.fade_in()

func _instant_transition(next_scene: Node, next_state: GameState) -> void:
	_deactivate_all_scenes()
	_activate_scene(next_scene, next_state)

# ============ MÉTODOS PÚBLICOS DE NAVEGAÇÃO ============

func go_to_menu(transition: String = "fade") -> void:
	change_scene_with_transition(menu_principal, GameState.MENU, transition)

func start_prologue(transition: String = "fade") -> void:
	change_scene_with_transition(prologue, GameState.PROLOGUE, transition)

func start_gameplay(transition: String = "fade") -> void:
	if gameplay:
		change_scene_with_transition(gameplay, GameState.PLAYING, transition)

func open_options(transition: String = "quick_fade") -> void:
	if menu_opcoes:
		change_scene_with_transition(menu_opcoes, GameState.OPTIONS, transition)

func quit_game() -> void:
	await TransitionScreen.fade_out()
	get_tree().quit()

# ============ HANDLERS DE BOTÕES ============

func _on_iniciar_pressed() -> void:
	start_prologue()

func _on_opcoes_pressed() -> void:
	open_options()

func _on_sair_pressed() -> void:
	quit_game()

func _on_voltar_menu_pressed() -> void:
	go_to_menu("slide_right")  # Efeito diferente para voltar

func _on_pular_prologue_pressed() -> void:
	start_gameplay()

# ============ MÉTODOS UTILITÁRIOS ============

func get_current_scene_name() -> String:
	return current_scene.name if current_scene else "None"

func get_current_state() -> GameState:
	return current_state

func is_in_state(state: GameState) -> bool:
	return current_state == state

# Método para pausar/despausar
func toggle_pause() -> void:
	if current_state == GameState.PLAYING:
		get_tree().paused = !get_tree().paused

# Debug
func debug_info() -> void:
	print("=== GAME DEBUG INFO ===")
	print("Cena atual: ", get_current_scene_name())
	print("Estado atual: ", GameState.keys()[current_state])
	print("Em transição: ", is_transitioning)
	print("TransitionScreen ativo: ", TransitionScreen.is_transitioning)
	print("========================")
