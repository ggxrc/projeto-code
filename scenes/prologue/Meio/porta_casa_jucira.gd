extends InteractiveObject

# Script para a porta da casa da Jucira
# Gerencia a transição entre exterior e interior da casa

# Referências aos nós principais
var exterior_vizinhos = null
var interior_vizinhos = null
var casa_idosa_ed = null
var loading_screen = null
var effects_node = null

func _ready() -> void:
	# Configurar texto de interação
	interaction_prompt = "Entrar na Casa"
	
	# Chamada para o _ready() da classe pai para configurar a área de interação
	super._ready()
	
	# Buscar referências aos nós necessários na cena Gameplay
	call_deferred("_setup_node_references")

# Configura as referências aos nós da cena
func _setup_node_references() -> void:
	var gameplay_scene = get_tree().current_scene
	
	if not gameplay_scene:
		print("ERRO: Cena atual não encontrada!")
		return
	
	# Buscar nós principais
	exterior_vizinhos = gameplay_scene.get_node_or_null("ExteriorVizinhos")
	interior_vizinhos = gameplay_scene.get_node_or_null("InteriorVizinhos")
	effects_node = gameplay_scene.get_node_or_null("Effects")
	
	if not exterior_vizinhos:
		print("ERRO: ExteriorVizinhos não encontrado!")
		return
		
	if not interior_vizinhos:
		print("ERRO: InteriorVizinhos não encontrado!")
		return
	
	# Buscar casa específica no interior
	casa_idosa_ed = interior_vizinhos.get_node_or_null("CasaIdosaEd")
	
	if not casa_idosa_ed:
		print("ERRO: CasaIdosaEd não encontrada em InteriorVizinhos!")
		return
	
	# Buscar tela de loading
	if effects_node:
		loading_screen = effects_node.get_node_or_null("LoadingScreen")
		if not loading_screen:
			print("AVISO: LoadingScreen não encontrada em Effects!")
	
	print("DEBUG: Referências configuradas com sucesso para porta da casa da Jucira")

# Sobrescreve o método interact para gerenciar a transição
func interact() -> void:
	if not interaction_enabled:
		print("Porta da casa da Jucira não pode ser interagida no momento")
		return
		
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_interaction_time < interaction_cooldown:
		return
		
	# Registra o tempo da interação
	last_interaction_time = current_time
	print("DEBUG: Entrando na casa da Jucira...")
	
	# Emite o sinal
	interaction_triggered.emit(self)
	
	# Inicia a transição para o interior
	_transition_to_interior()

# Gerencia a transição do exterior para o interior da casa
func _transition_to_interior() -> void:
	# Verifica se as referências estão configuradas
	if not exterior_vizinhos or not interior_vizinhos or not casa_idosa_ed:
		print("ERRO: Referências de nós não configuradas!")
		return
	
	# Desabilita movimento do jogador durante transição
	_disable_player_movement()
	
	# Mostra tela de loading se disponível
	if loading_screen:
		print("DEBUG: Mostrando tela de loading...")
		loading_screen.visible = true
		if loading_screen.has_method("show_loading"):
			loading_screen.show_loading()
		
		# Aguarda um frame para que a tela de loading seja exibida
		await get_tree().process_frame
	
	# Esconde o exterior (torna invisível, não remove da cena)
	print("DEBUG: Escondendo ExteriorVizinhos...")
	exterior_vizinhos.visible = false
	
	# Mostra o interior da casa da Jucira
	print("DEBUG: Mostrando interior da casa da Jucira...")
	interior_vizinhos.visible = true
	casa_idosa_ed.visible = true
	
	# Posiciona o jogador no interior (opcional - na entrada da casa)
	_position_player_in_interior()
	
	# Aguarda um tempo para simular loading
	await get_tree().create_timer(1.0).timeout
	
	# Esconde tela de loading
	if loading_screen:
		print("DEBUG: Escondendo tela de loading...")
		loading_screen.visible = false
		if loading_screen.has_method("hide_loading"):
			loading_screen.hide_loading()
	
	# Reabilita movimento do jogador
	_enable_player_movement()
	
	print("DEBUG: Transição para interior da casa da Jucira concluída!")

# Posiciona o jogador no interior da casa
func _position_player_in_interior() -> void:
	var player = _find_player()
	if not player:
		print("AVISO: Jogador não encontrado para reposicionamento!")
		return
	
	# Define uma posição inicial dentro da casa (ajustar conforme necessário)
	# Você pode definir uma posição específica ou procurar por um marcador
	var initial_position = Vector2(400, 300)  # Posição inicial padrão
	
	# Procura por um marcador de spawn no interior da casa (opcional)
	var spawn_point = casa_idosa_ed.get_node_or_null("PlayerSpawnPoint")
	if spawn_point:
		initial_position = spawn_point.global_position
		print("DEBUG: Usando spawn point encontrado na casa")
	
	player.global_position = initial_position
	print("DEBUG: Jogador posicionado em: ", initial_position)

# Desativa o movimento do jogador durante a transição
func _disable_player_movement() -> void:
	var player = _find_player()
	if not player:
		print("AVISO: Jogador não encontrado para desabilitar movimento!")
		return
	
	print("DEBUG: Desabilitando movimento do jogador...")
	
	# Tenta métodos comuns para desabilitar movimento
	if player.has_method("set_can_move"):
		player.set_can_move(false)
	elif player.has_method("disable_movement"):
		player.disable_movement()
	elif "can_move" in player:
		player.can_move = false
	elif "movement_enabled" in player:
		player.movement_enabled = false
	else:
		# Último recurso: desabilitar processos
		player.set_process_input(false)
		player.set_physics_process(false)
		print("DEBUG: Movimento do jogador desabilitado via processos")

# Reabilita o movimento do jogador após a transição
func _enable_player_movement() -> void:
	var player = _find_player()
	if not player:
		print("AVISO: Jogador não encontrado para reabilitar movimento!")
		return
	
	print("DEBUG: Reabilitando movimento do jogador...")
	
	# Tenta métodos comuns para reabilitar movimento
	if player.has_method("set_can_move"):
		player.set_can_move(true)
	elif player.has_method("enable_movement"):
		player.enable_movement()
	elif "can_move" in player:
		player.can_move = true
	elif "movement_enabled" in player:
		player.movement_enabled = true
	else:
		# Último recurso: reabilitar processos
		player.set_process_input(true)
		player.set_physics_process(true)
		print("DEBUG: Movimento do jogador reabilitado via processos")

# Função auxiliar para encontrar o jogador na cena
func _find_player() -> Node:
	# Método 1: Verificar se existe um nó no grupo "player"
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	
	# Método 2: Procurar pelo nome do nó
	var gameplay_scene = get_tree().current_scene
	if gameplay_scene:
		var player = gameplay_scene.find_child("Player", true, false)
		if player:
			return player
		
		# Tentar no ExteriorVizinhos
		if exterior_vizinhos:
			player = exterior_vizinhos.find_child("Player", true, false)
			if player:
				return player
	
	print("ERRO: Jogador não encontrado na cena!")
	return null

# Método para depuração
func _to_string() -> String:
	return "PortaCasaJucira(exterior_visible: %s, interior_visible: %s)" % [
		exterior_vizinhos.visible if exterior_vizinhos else "null",
		interior_vizinhos.visible if interior_vizinhos else "null"
	]
