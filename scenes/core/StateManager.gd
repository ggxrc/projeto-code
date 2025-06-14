extends Node
# StateManager.gd
# Gerencia os estados do jogo e transições entre eles

signal state_changed(old_state, new_state)

# Estados do jogo como strings para maior flexibilidade
var _states = {}
var current_state = ""
var previous_state = ""
var return_to_state = ""  # Estado ao qual retornar após pausar

# Flag para controle de pausa
var pause_enabled = true

# Flags de progresso do jogo
var prologue_completed = false

# Inicialização
func _ready() -> void:
	print("StateManager: Inicializado.")

# Método para pausar o jogo (chamado pelo botão de pausa da UI)
func pause_game():
	if pause_enabled:
		if current_state != "Paused" and current_state != "MainMenu" and current_state != "Config":
			# Salve o estado atual e vá para o estado de pausa
			return_to_state = current_state
			change_state("Paused")
			get_tree().paused = true
			
			# Configurar o menu de pausa
			var pause_menu = get_node_or_null("/root/Main/UI/PauseMenu")
			if pause_menu:
				pause_menu.set_previous_state(return_to_state)
				pause_menu.visible = true

# Adiciona um estado ao gerenciador
func add_state(state_name):
	_states[state_name] = state_name
	print("StateManager: Estado '%s' adicionado." % state_name)

# Muda para um novo estado
func change_state(new_state):
	if not _states.has(new_state):
		push_error("StateManager: Tentativa de mudar para estado desconhecido: %s" % new_state)
		return

	if new_state == current_state:
		print("StateManager: Já estamos no estado %s" % new_state)
		return
		
	print("StateManager: Mudando de '%s' para '%s'" % [current_state, new_state])
	
	# Armazena o estado anterior
	previous_state = current_state
	
	# Lida com estados específicos
	if new_state == "Paused":
		# Configurar pausa
		get_tree().paused = true
	elif previous_state == "Paused":
		# Saindo da pausa
		get_tree().paused = false
	
	print("StateManager: Mudança de estado %s -> %s" % [current_state, new_state])
		# Atualiza o estado atual
	current_state = new_state
	
	# Notificar o SceneManager para carregar a cena correspondente
	var service_locator = $"/root/ServiceLocator"
	if service_locator:
		var scene_manager = service_locator.get_service("SceneManager")
		if scene_manager:
			scene_manager.load_scene_for_state(new_state)
	
	# Notifica observadores sobre a mudança de estado
	emit_signal("state_changed", previous_state, current_state)

# Retorna ao estado anterior
func return_to_previous() -> void:
	if previous_state != "":
		change_state(previous_state)
	else:
		change_state("MainMenu") # Fallback seguro

# Retorna ao estado de retorno definido (útil ao sair da pausa)
func return_to_saved_state() -> void:
	if return_to_state != "":
		change_state(return_to_state)
	else:
		change_state("MainMenu") # Fallback seguro

# Verifica se o jogo está em um estado específico
func is_in_state(state) -> bool:
	return current_state == state

# Obtém o nome do estado atual (útil para debug)
func get_current_state_name() -> String:
	return current_state

# Habilita ou desabilita a funcionalidade de pausa
func set_pause_enabled(enabled: bool) -> void:
	pause_enabled = enabled
	print("StateManager: Pausa " + ("habilitada" if enabled else "desabilitada"))

# Verifica se um estado é pausável
func is_pausable_state(state_name: String) -> bool:
	var pausable_states = ["Gameplay", "Prologue"]
	return state_name in pausable_states
