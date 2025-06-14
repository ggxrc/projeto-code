extends Node
class_name SystemIntegrationAdapter

# Guia de migração para a nova arquitetura
# Este script é um guia de como migrar do sistema antigo para o novo sistema modular
# e deve ser adicionado como um nó filho na cena Game.tscn

# Referência ao SystemManager e outros sistemas
var system_manager: SystemManager
var scene_system
var dialogue_system
var input_system
var save_system
var ui_system
var audio_system

func _ready() -> void:
	print("SystemIntegrationAdapter: Iniciando integração...")
	
	# Carregar o SystemManager
	var system_manager_script = load("res://systems/SystemManager.gd")
	system_manager = system_manager_script.new()
	system_manager.name = "SystemManager"
	add_child(system_manager)
	
	# Conectar o sinal de inicialização dos sistemas
	system_manager.systems_initialized.connect(_on_systems_initialized)
	
	# Usar o SceneContainer já existente na cena Game
	var game_node = get_parent()
	if game_node:
		# Já existe um SceneContainer como nó irmão na mesma cena
		var scene_container = game_node.get_node_or_null("SceneContainer")
		if scene_container:
			# Referência direta ao container existente para o SystemManager usar
			system_manager.scene_container = scene_container
			print("SystemIntegrationAdapter: Usando SceneContainer já existente")
	
	# Configurar timer para verificar status dos sistemas (útil para depuração)
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.timeout.connect(func(): system_manager.debug_print_systems_status())
	add_child(timer)
	timer.start()

func _on_systems_initialized():
	print("SystemIntegrationAdapter: Sistemas inicializados!")
	
	# Obter referências para todos os sistemas
	scene_system = system_manager.get_scene_system()
	dialogue_system = system_manager.get_dialogue_system()
	input_system = system_manager.get_input_system()
	save_system = system_manager.get_save_system()
	ui_system = system_manager.get_ui_system()
	audio_system = system_manager.get_audio_system()
	
	# Verificar se todos os sistemas essenciais foram carregados
	if not scene_system:
		push_error("SystemIntegrationAdapter: ERRO - scene_system não foi inicializado!")
		return
	
	# Confirmar que o registro de métodos está funcionando
	print("SystemIntegrationAdapter: scene_system inicializado: " + str(scene_system.get_class()) + 
		  ", possui método register_game_enum: " + str(scene_system.has_method("register_game_enum")))
	
	# Configurar integrações
	_setup_scene_system_integration()
	_setup_dialogue_system_integration()
	_setup_input_system_integration()
	_setup_ui_system_integration()
	_setup_audio_system_integration()
	_setup_save_system_integration()
	
	print("SystemIntegrationAdapter: Migração completa!")

# Configurar integração do sistema de cenas
func _setup_scene_system_integration():
	var game_node = get_parent()
	
	# Verificar se o scene_system foi inicializado corretamente
	if not scene_system:
		push_error("SystemIntegrationAdapter: scene_system não foi inicializado")
		return
		
	# Conectar sinais do Game para SceneManager
	if game_node and game_node.has_signal("game_state_changed"):
		game_node.game_state_changed.connect(
			func(new_state): 
				scene_system.emit_signal("game_state_changed", new_state)
		)
	
	# Adicionar suporte para GameState enum
	if game_node and "GameState" in game_node:
		if scene_system.has_method("register_game_enum"):
			scene_system.register_game_enum(game_node.GameState)
		else:
			push_error("SystemIntegrationAdapter: scene_system não possui o método register_game_enum")
			
	# Configurar container de cenas - já deve estar definido,
	# mas garantimos aqui caso o fluxo de inicialização seja diferente
	var container = get_parent().get_node_or_null("SceneContainer")
	if container:
		scene_system.set_scene_container(container)
	else:
		print("SystemIntegrationAdapter: AVISO - SceneContainer não encontrado")

# Configurar integração do sistema de diálogos
func _setup_dialogue_system_integration():
	dialogue_system.set_dialogue_directory("res://assets/dialogues")
	
	# Conectar sistemas de UI e Diálogo
	dialogue_system.dialogue_started.connect(
		func(dialogue_data): 
			ui_system.show_dialogue_box(dialogue_data)
	)
	
	dialogue_system.dialogue_choice_started.connect(
		func(choices): 
			ui_system.show_dialogue_choices(choices)
	)
	
	ui_system.choice_selected.connect(
		func(choice_index): 
			dialogue_system.process_choice(choice_index)
	)

# Configurar integração do sistema de input
func _setup_input_system_integration():
	input_system.initialize_detection()
	
	# Conectar sinais de pausa
	input_system.pause_requested.connect(
		func(): 
			var game_node = get_parent()
			if game_node and game_node.has_method("toggle_pause"):
				game_node.toggle_pause()
	)

# Configurar integração do sistema de UI
func _setup_ui_system_integration():
	# Registrar camadas de UI
	ui_system.register_layer("hud", 10)
	ui_system.register_layer("dialogue", 20)
	ui_system.register_layer("pause", 30)
	ui_system.register_layer("loading", 40)
	
	# Conectar sistemas de áudio e UI para feedback sonoro
	ui_system.button_hovered.connect(
		func(button_name): 
			audio_system.play_sfx("hover.ogg")
	)
	
	ui_system.button_pressed.connect(
		func(button_name): 
			audio_system.play_sfx("click.ogg")
	)

# Configurar integração do sistema de áudio
func _setup_audio_system_integration():
	# Conectar sistemas de diálogo e áudio
	dialogue_system.dialogue_started.connect(
		func(dialogue_data): 
			audio_system.play_sfx("dialogue_start.ogg")
	)
	
	dialogue_system.dialogue_completed.connect(
		func(): 
			audio_system.play_sfx("dialogue_end.ogg")
	)
	
	dialogue_system.dialogue_choice_started.connect(
		func(choices): 
			audio_system.play_sfx("dialogue_choice.ogg")
	)
	
	# Configurar música de fundo
	audio_system.preload_audio(
		["menu_theme.ogg", "prologue_theme.ogg", "gameplay_theme.ogg"], 
		["dialogue_start.ogg", "dialogue_end.ogg", "dialogue_choice.ogg", "hover.ogg", "click.ogg"]
	)

# Configurar integração do sistema de salvamento
func _setup_save_system_integration():
	save_system.set_save_directory("user://saves")
	
	# Configurações padrão
	var default_settings = {
		"audio": {
			"music_volume": 0.8,
			"sfx_volume": 1.0,
			"master_volume": 1.0,
			"is_music_enabled": true,
			"is_sfx_enabled": true
		},
		"display": {
			"fullscreen": false,
			"resolution": "1280x720",
			"vsync": true
		},
		"gameplay": {
			"difficulty": "normal",
			"show_hints": true
		},
		"controls": {
			"invert_y": false,
			"sensitivity": 0.5
		}
	}
	
	save_system.set_default_settings(default_settings)
	
	# Carregar configurações existentes
	save_system.load_settings()
	
	# Aplicar configurações de áudio
	var audio_settings = save_system.get_settings().get("audio", {})
	if not audio_settings.is_empty():
		audio_system.load_audio_settings(audio_settings)

# Métodos para uso em scripts legados
# Esses métodos servem como ponte para o novo sistema

# Métodos de mudança de cena
func change_scene(scene_path: String, transition_type: String = "fade") -> void:
	scene_system.change_scene_to(scene_path, transition_type)

func activate_scene(scene_node: Node) -> void:
	scene_system.activate_scene(scene_node)

# Métodos de diálogo
func start_dialogue(dialogue_id: String) -> void:
	dialogue_system.start_dialogue(dialogue_id)

func show_description(description_text: String, duration: float = 3.0) -> void:
	dialogue_system.show_description(description_text, duration)

# Métodos de UI
func show_notification(message: String, type: String = "info") -> void:
	ui_system.show_notification(message, type)

func toggle_ui_element(element_name: String, visible: bool) -> void:
	ui_system.toggle_element(element_name, visible)

# Métodos de áudio
func play_music(music_name: String) -> void:
	audio_system.play_music(music_name)

func play_sound(sound_name: String) -> void:
	audio_system.play_sfx(sound_name)

# Métodos de salvamento
func save_game(slot: int = 1) -> void:
	save_system.save_game(slot)

func load_game(slot: int = 1) -> void:
	save_system.load_game(slot)
