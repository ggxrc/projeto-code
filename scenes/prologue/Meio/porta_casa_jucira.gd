extends InteractiveObject

# Script para a porta da casa da Jucira
# Gerencia a transição entre exterior e interior da casa

# Referências aos nós principais
var interior_vizinhos = null
var casa_idosa_ed = null
var transition_screen = null
var loading_screen = null

func _ready() -> void:
	# Configurar texto de interação
	interaction_prompt = "Entrar na Casa"
	
	# Chamada para o _ready() da classe pai para configurar a área de interação
	super._ready()
	
	# Buscar referências aos nós necessários na cena Gameplay
	call_deferred("_setup_node_references")

# Sobrescreve o método da classe pai para posicionar a área interativa na posição correta
func _setup_interaction_area() -> void:
	# Verifica se já existe uma área de interação
	if has_node("InteractionArea"):
		area_node = get_node("InteractionArea")
		# Ajusta a posição da área existente
		area_node.position = Vector2(22.1428, 23.5714)
		return
		
	# Cria a área de interação
	area_node = Area2D.new()
	area_node.name = "InteractionArea"
	
	# Define a posição específica da porta da Jucira
	area_node.position = Vector2(22.1428, 23.5714)
	
	# Adiciona forma de colisão
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = interaction_area_size
	collision.shape = shape
	
	# Adiciona um ColorRect para visualizar a área durante o desenvolvimento
	var debug_rect = ColorRect.new()
	debug_rect.color = Color(0, 1, 0, 0.2)  # Verde semi-transparente
	debug_rect.size = interaction_area_size
	debug_rect.position = -interaction_area_size / 2  # Centraliza o retângulo
	
	area_node.add_child(collision)
	area_node.add_child(debug_rect)
	
	# Conecta sinais de entrada/saída
	area_node.body_entered.connect(_on_body_entered)
	area_node.body_exited.connect(_on_body_exited)
	
	# Adiciona à árvore
	add_child(area_node)
	print("InteractiveObject: Área de interação configurada para porta da Jucira na posição ", area_node.position)

# Configura as referências aos nós da cena
func _setup_node_references() -> void:
	var gameplay_scene = get_tree().current_scene
	
	# Buscar nós principais do Gameplay
	interior_vizinhos = gameplay_scene.get_node_or_null("InteriorVizinhos")
	if interior_vizinhos:
		casa_idosa_ed = interior_vizinhos.get_node_or_null("CasaIdosaEd")
	
	# Buscar as telas de transição primeiro no Game (parent do Gameplay)
	var game_node = gameplay_scene.get_parent()
	if game_node and game_node.name == "Game":
		var effects = game_node.get_node_or_null("Effects")
		if effects:
			transition_screen = effects.get_node_or_null("TransitionScreen")
			loading_screen = effects.get_node_or_null("LoadingScreen")
			print("DEBUG: Usando TransitionScreen e LoadingScreen do Game/Effects")
	
	# Se não encontrou no Game, busca no próprio Gameplay
	if not transition_screen or not loading_screen:
		var gameplay_effects = gameplay_scene.get_node_or_null("Effects")
		if gameplay_effects:
			if not transition_screen:
				transition_screen = gameplay_effects.get_node_or_null("TransitionScreen")
				print("DEBUG: Usando TransitionScreen do Gameplay/Effects")
			if not loading_screen:
				loading_screen = gameplay_effects.get_node_or_null("LoadingScreen")
				print("DEBUG: Usando LoadingScreen do Gameplay/Effects")
	
	# Fallback final para autoloads se não encontrou em lugar nenhum
	if not transition_screen:
		transition_screen = TransitionScreen
		print("DEBUG: Usando TransitionScreen autoload")
	if not loading_screen:
		loading_screen = LoadingScreen
		print("DEBUG: Usando LoadingScreen autoload")
	
	print("DEBUG: Referências configuradas - InteriorVizinhos:", interior_vizinhos != null)
	print("DEBUG: CasaIdosaEd:", casa_idosa_ed != null)
	print("DEBUG: TransitionScreen:", transition_screen != null)
	print("DEBUG: LoadingScreen:", loading_screen != null)

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
	if not interior_vizinhos or not casa_idosa_ed:
		print("ERRO: Referências de nós não configuradas!")
		return
	
	print("DEBUG: Iniciando transição para interior da casa da Jucira...")
	
	# Desabilita movimento do jogador durante transição
	_disable_player_movement()
		# Executa a mesma sequência que o Game.gd usa para transições com loading:
	# 1. Fade out com TransitionScreen
	if transition_screen and transition_screen.has_method("fade_out"):
		print("DEBUG: Fazendo fade out...")
		await transition_screen.fade_out()
	else:
		print("ERRO: TransitionScreen não disponível!")
		return
	
	# 2. Muda a estrutura da cena (equivalente ao _deactivate_all_main_scenes + _activate_scene)
	print("DEBUG: Ativando interior e movendo jogador...")
	interior_vizinhos.visible = true
	casa_idosa_ed.visible = true
	_teleport_player_to_interior()
	
	# 3. Mostra tela de loading
	if loading_screen and loading_screen.has_method("start_loading"):
		print("DEBUG: Iniciando loading screen...")
		loading_screen.start_loading(false) # false = sem transições internas, pois já fizemos fade_out
		await loading_screen.loading_finished
		print("DEBUG: Loading concluído!")
	else:
		print("AVISO: LoadingScreen não disponível!")
		# Fallback com timer
		await get_tree().create_timer(1.5).timeout
	
	# 4. Fade in para revelar a nova configuração
	if transition_screen and transition_screen.has_method("fade_in"):
		print("DEBUG: Fazendo fade in...")
		await transition_screen.fade_in()
	else:
		print("ERRO: TransitionScreen não disponível para fade in!")
	
	# Reabilita movimento do jogador
	_enable_player_movement()
	
	print("DEBUG: Transição para interior da casa da Jucira concluída!")

# Teleporta o jogador para a posição específica no interior da casa
func _teleport_player_to_interior() -> void:
	var player = _find_player()
	if not player:
		print("AVISO: Jogador não encontrado para teleporte!")
		return
	
	# Remove o jogador da sua posição atual na árvore
	var original_parent = player.get_parent()
	if original_parent:
		print("DEBUG: Removendo jogador de: ", original_parent.name)
		original_parent.remove_child(player)
		# Move o jogador para dentro da casa da Jucira
	if casa_idosa_ed:
		print("DEBUG: Movendo jogador para CasaIdosaEd...")
		casa_idosa_ed.add_child(player)
		
		# Define a posição específica solicitada: x: 700, y: 500
		var target_position = Vector2(700, 480)
		player.position = target_position  # Usa position local, não global
		
		print("DEBUG: Jogador movido para CasaIdosaEd na posição: ", target_position)
	else:
		print("ERRO: CasaIdosaEd não disponível para mover o jogador!")
		# Se falhar, coloca de volta no pai original
		if original_parent:
			original_parent.add_child(player)
		return

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
		
		# Tentar no InteriorVizinhos
		if interior_vizinhos:
			player = interior_vizinhos.find_child("Player", true, false)
			if player:
				return player
	
	print("ERRO: Jogador não encontrado na cena!")
	return null

# Método para depuração
func _to_string() -> String:
	return "PortaCasaJucira(interior_visible: %s)" % [
		interior_vizinhos.visible if interior_vizinhos else "null"
	]
