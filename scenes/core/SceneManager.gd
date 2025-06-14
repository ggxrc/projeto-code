extends Node
# SceneManager.gd
# Gerencia o carregamento, transição e liberação de cenas

signal transition_started
signal transition_finished
signal scene_loaded(scene_name)
signal scene_unloaded(scene_name)
signal scene_changed(from_scene, to_scene)
signal loading_progress(progress_value)

# Tipos de transições disponíveis
enum TransitionType {
	NONE,       # Sem transição
	FADE,       # Fade para preto e depois revela
	DISSOLVE,   # Dissolve entre cenas
	LOADING,    # Tela de carregamento
	INSTANT     # Troca instantânea
}

# Referências
var scene_container = null  # Node onde as cenas serão carregadas
var loading_screen = null   # Referência para a tela de loading

# Cena atual
var current_scene = null
var current_scene_path = ""
# Cena que está sendo carregada
var scene_being_loaded = ""
# Flag para indicar que uma transição está em andamento
var is_transitioning = false

# Mapeamento de estados para caminhos de cenas
var state_to_scene_map = {}

# Inicialização
func _ready() -> void:
	print("SceneManager: Inicializado e pronto para gerenciar cenas.")

# Define o contêiner onde as cenas serão carregadas
func set_scene_container(container):
	scene_container = container
	print("SceneManager: Contêiner de cenas configurado.")

# Define a tela de carregamento
func set_loading_screen(screen):
	loading_screen = screen
	print("SceneManager: Tela de carregamento configurada.")
	
# Mapeia um estado para uma cena
func map_state_to_scene(state_name: String, scene_path: String) -> void:
	state_to_scene_map[state_name] = scene_path
	print("SceneManager: Estado '%s' mapeado para cena '%s'" % [state_name, scene_path])

# Carrega a cena correspondente a um estado
func load_scene_for_state(state_name: String) -> void:
	if not state_to_scene_map.has(state_name):
		push_error("SceneManager: Não há cena mapeada para o estado '%s'" % state_name)
		return
		
	var scene_path = state_to_scene_map[state_name]
	change_scene(scene_path)

# Carrega e muda para uma cena pelo caminho
func change_scene(scene_path: String, transition_type: int = TransitionType.FADE) -> void:
	if is_transitioning:
		push_warning("SceneManager: Já existe uma transição em andamento.")
		return
		
	if scene_path == current_scene_path:
		print("SceneManager: A cena '%s' já está carregada." % scene_path)
		return
		
	print("SceneManager: Carregando cena '%s'" % scene_path)
	is_transitioning = true
	scene_being_loaded = scene_path
	
	# Iniciar transição
	emit_signal("transition_started")
	
	# Realizar transição adequada
	match transition_type:
		TransitionType.NONE:
			_do_scene_change(scene_path)
		TransitionType.INSTANT:
			_do_scene_change(scene_path)
		TransitionType.FADE:
			await _fade_transition(scene_path)
		TransitionType.DISSOLVE:
			await _fade_transition(scene_path) # Por enquanto, igual ao fade
		TransitionType.LOADING:
			await _loading_transition(scene_path)
		_:
			_do_scene_change(scene_path)
			
	emit_signal("transition_finished")
	is_transitioning = false

# Realiza uma transição com fade
func _fade_transition(scene_path: String) -> void:
	# Fade out
	if loading_screen:
		loading_screen.show_screen()
		await get_tree().create_timer(0.5).timeout
		
	# Trocar cena
	_do_scene_change(scene_path)
	
	# Fade in
	if loading_screen:
		await get_tree().create_timer(0.5).timeout
		loading_screen.hide_screen()
		
# Realiza uma transição com tela de carregamento
func _loading_transition(scene_path: String) -> void:
	# Mostrar tela de carregamento
	if loading_screen:
		loading_screen.show_screen()
		
	# Esperar um momento para mostrar a tela
	await get_tree().create_timer(0.2).timeout
	
	# Carregar a cena em background
	var loader = ResourceLoader.load_threaded_request(scene_path)
	if loader == null:
		push_error("SceneManager: Erro ao carregar a cena '%s'" % scene_path)
		return
		
	var progress = [0.0]
	var res = ResourceLoader.load_threaded_get_status(scene_path, progress)
	
	# Atualizar progresso
	while res == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		var load_progress = progress[0] * 100
		if loading_screen:
			loading_screen.update_progress(progress[0])
		emit_signal("loading_progress", progress[0])
		await get_tree().create_timer(0.1).timeout
		res = ResourceLoader.load_threaded_get_status(scene_path, progress)
		
	# Verificar se carregou com sucesso
	if res != ResourceLoader.THREAD_LOAD_LOADED:
		push_error("SceneManager: Falha ao carregar a cena '%s'" % scene_path)
		return
		
	var scene_resource = ResourceLoader.load_threaded_get(scene_path)
	var new_scene = scene_resource.instantiate()
	
	# Descartar cena atual
	if current_scene:
		current_scene.queue_free()
		
	# Configurar nova cena
	scene_container.add_child(new_scene)
	current_scene = new_scene
	current_scene_path = scene_path
	
	# Emitir sinais
	emit_signal("scene_changed", scene_being_loaded, scene_path)
	emit_signal("scene_loaded", scene_path)
	
	# Fechar tela de carregamento
	if loading_screen:
		await get_tree().create_timer(0.5).timeout
		loading_screen.hide_screen()

# Executa a troca de cena propriamente dita
func _do_scene_change(scene_path: String) -> void:
	# Verifica se a cena existe
	if not ResourceLoader.exists(scene_path):
		push_error("SceneManager: Cena '%s' não existe!" % scene_path)
		return
		
	# Descarrega cena atual
	if current_scene:
		emit_signal("scene_unloaded", current_scene_path)
		current_scene.queue_free()
		
	# Carregar nova cena
	var new_scene = load(scene_path).instantiate()
	if not scene_container:
		push_error("SceneManager: scene_container não está configurado!")
		return
		
	# Adiciona nova cena ao contêiner
	scene_container.add_child(new_scene)
	current_scene = new_scene
	current_scene_path = scene_path
	
	# Emitir sinais
	emit_signal("scene_changed", scene_being_loaded, scene_path)
	emit_signal("scene_loaded", scene_path)
