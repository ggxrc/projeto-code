extends Node

# Script principal para controle do jogo
# Inicializa e registra todos os sistemas no ServiceLocator

# Referências para os gerenciadores
@onready var scene_manager = $"/root/SceneManager"
@onready var state_manager = $"/root/StateManager"
@onready var audio_manager = $AudioManager
@onready var scene_container = $SceneContainer
@onready var hud = $UI/HUD
@onready var loading_screen = $UI/LoadingScreen

# Constantes
const INITIAL_SCENE = "res://scenes/main menu/MenuPrincipal.tscn"

func _ready():
	# Primeiro, verificar componentes básicos
	if not scene_container:
		push_error("scene_container não está definido!")
		return
	
	if not loading_screen:
		push_error("loading_screen não está definido!")
		return
		
	# Registrar todos os gerenciadores no ServiceLocator
	var service_locator = $"/root/ServiceLocator"
	if not service_locator:
		push_error("ServiceLocator não encontrado!")
		return
		
	# Registrar serviços
	print("Registrando serviços...")
	service_locator.register_service("SceneManager", scene_manager)
	service_locator.register_service("StateManager", state_manager)
	service_locator.register_service("AudioManager", audio_manager)
	service_locator.register_service("HUD", hud)
	
	# Todas as configurações e conexões serão feitas em _connect_signals
	# para garantir que tudo esteja registrado primeiro
	call_deferred("_connect_signals")
	
func _connect_signals():
	# Esta função é chamada através de call_deferred, garantindo que
	# todos os nós já estejam prontos antes de configurar as conexões
	print("Inicializando gerenciadores e conectando sinais...")
	
	# 1. Configurar SceneManager
	if not scene_manager:
		push_error("scene_manager é nulo!")
		return
		
	print("Configurando SceneManager...")
	scene_manager.set_scene_container(scene_container)
	scene_manager.set_loading_screen(loading_screen)
	
	# 2. Configurar estados
	print("Configurando estados do jogo...")
	_setup_game_states()
	
	# 3. Conectar sinais - Isso deve ser feito DEPOIS de todas as configurações
	print("Conectando sinais...")
	scene_manager.transition_started.connect(_on_scene_transition_started)
	scene_manager.transition_finished.connect(_on_scene_transition_finished)
	
	# Conectar sinal de pausa do HUD
	if hud:
		hud.pause_requested.connect(_on_pause_requested)
	
	# 4. Iniciar o jogo carregando a cena inicial
	print("Iniciando no menu principal...")
	state_manager.change_state("MainMenu")

# Configurar estados do jogo e mapeamento para cenas
func _setup_game_states():
	# Definir estados do jogo
	state_manager.add_state("MainMenu")
	state_manager.add_state("Prologue")
	state_manager.add_state("Gameplay")
	state_manager.add_state("Paused")
	state_manager.add_state("GameOver")
	state_manager.add_state("Credits")
	state_manager.add_state("Config")
		# Mapear estados para cenas
	scene_manager.map_state_to_scene("MainMenu", "res://scenes/ui/menus/main_menu/MenuPrincipal.tscn")
	scene_manager.map_state_to_scene("Prologue", "res://scenes/gameplay/levels/prologue/PrologueLevel.tscn") 
	scene_manager.map_state_to_scene("Gameplay", "res://scenes/gameplay/levels/Level1.tscn")
	scene_manager.map_state_to_scene("Credits", "res://scenes/ui/menus/Credits.tscn")
	scene_manager.map_state_to_scene("Config", "res://scenes/ui/menus/Config.tscn")

# Callbacks para transições de cena
func _on_scene_transition_started():
	loading_screen.show_screen()

func _on_scene_transition_finished():
	loading_screen.hide_screen()

func _on_pause_requested():
	if state_manager:
		state_manager.pause_game()
