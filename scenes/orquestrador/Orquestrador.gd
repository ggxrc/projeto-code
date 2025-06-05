# /cenas/Orquestrador.gd - Versão de compatibilidade com sua estrutura atual
extends Node

# Referência para o node Game (pai)
@onready var game_node = get_parent()

# Referencias diretas (mantém compatibilidade)
@onready var menu_principal = $"../MenuPrincipal"
@onready var prologue = $"../Prologue"

# Referência aos autoloads
@onready var loading_screen = get_node_or_null("/root/LoadingScreen")

var scenes: Array[Node]
var current_scene: Node

func _ready() -> void:
	# Compatibilidade com código antigo
	scenes = [
		menu_principal,
		prologue
	]
	
	# Remove referências nulas
	scenes = scenes.filter(func(scene): return scene != null)
	
	# Usa o novo sistema através do Game node
	if game_node and game_node.has_method("_setup_initial_state"):
		# Se Game tem o novo sistema, delega para ele
		pass
	else:
		# Fallback para sistema antigo melhorado
		_setup_legacy_system()

func _setup_legacy_system() -> void:
	_hide_all_scenes()
	_show_scene(menu_principal)

func _hide_all_scenes() -> void:
	for scene in scenes:
		if scene:
			scene.visible = false
			scene.process_mode = Node.PROCESS_MODE_DISABLED

func _show_scene(scene: Node) -> void:
	if scene:
		scene.visible = true
		scene.process_mode = Node.PROCESS_MODE_INHERIT
		current_scene = scene

# ============ MÉTODOS PÚBLICOS (Mantém compatibilidade) ============

func scene_transition(next_scene: Node) -> void:
	# Versão antiga sem transição
	_hide_all_scenes()
	_show_scene(next_scene)

func scene_transition_with_fade(next_scene: Node) -> void:
	# Nova versão com fade
	if TransitionScreen:
		await TransitionScreen.transition_with_callback(_change_scene_callback.bind(next_scene))
	else:
		scene_transition(next_scene)

func _change_scene_callback(next_scene: Node) -> void:
	_hide_all_scenes()
	_show_scene(next_scene)

func scene_transition_with_loading(next_scene: Node) -> void:
	# Versão com tela de loading
	if not TransitionScreen or not loading_screen:
		scene_transition(next_scene)
		return
	
	# Primeiro usa TransitionScreen para fade out
	await TransitionScreen.fade_out()
	
	# Esconde todas as cenas
	_hide_all_scenes()
	
	# Mostra a tela de loading com tempo aleatório
	loading_screen.start_loading(false) # false = não usar transições internas
	await loading_screen.loading_finished
	
	# Mostra a próxima cena
	_show_scene(next_scene)
	
	# Faz fade in para revelar a cena
	await TransitionScreen.fade_in()

# ============ MÉTODOS DE CONVENIÊNCIA ============

func go_to_menu(with_transition: bool = true) -> void:
	if game_node and game_node.has_method("go_to_menu"):
		game_node.go_to_menu()
	elif with_transition:
		scene_transition_with_loading(menu_principal)
	else:
		scene_transition(menu_principal)

func start_prologue(with_transition: bool = true) -> void:
	if game_node and game_node.has_method("start_prologue"):
		game_node.start_prologue()
	elif with_transition:
		scene_transition_with_loading(prologue)  
	else:
		scene_transition(prologue)

func quit_game() -> void:
	if game_node and game_node.has_method("quit_game"):
		game_node.quit_game()
	else:
		if TransitionScreen:
			await TransitionScreen.fade_out()
		get_tree().quit()

# ============ HANDLERS (Mantém compatibilidade) ============

func _on_voltar_menu_pressed() -> void:
	go_to_menu()

func _on_iniciar_pressed() -> void:
	start_prologue()

func _on_sair_pressed() -> void:
	quit_game()
