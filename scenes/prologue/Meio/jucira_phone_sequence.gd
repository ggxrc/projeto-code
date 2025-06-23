extends Node

# Este script gerencia a sequência de eventos do telefonema da Jucira
# Ordem dos eventos: telefone toca > Jucira pede ajuda > telefone desliga > diálogo > retorno ao gameplay

# Sinais para coordenar a sequência
signal sequence_started
signal sequence_finished
signal dialogue_step_completed

# Referências para as caixas de diálogo
var dialogue_box = null
var description_box = null

# Estado da sequência
var sequence_step = 0
var is_sequence_active = false

# Configurações
var dialogue_speed = 0.03

func _ready() -> void:
	print("DEBUG: Script da sequência do telefone da Jucira inicializado")
	set_process_input(false) # Desativa input até a sequência começar

# Inicializa a sequência
func start_sequence() -> void:
	print("DEBUG: start_sequence() chamado")
	sequence_step = 0
	is_sequence_active = true
	set_process_input(true)
	
	# Garantir que o nó esteja totalmente pronto antes de continuar
	call_deferred("_deferred_start_sequence")

# Inicia a sequência após garantir que o nó esteja pronto
func _deferred_start_sequence() -> void:
	print("DEBUG: _deferred_start_sequence chamado")
	
	# Verificar se já está na árvore
	if not is_inside_tree():
		print("DEBUG: Nó ainda não está na árvore. Esperando...")
		await tree_entered
		print("DEBUG: Nó agora está na árvore.")
	
	# Emitir sinal de início
	print("DEBUG: Emitindo sinal sequence_started")
	sequence_started.emit()
	
	# Configura as caixas de diálogo com segurança
	call_deferred("setup_dialogue_boxes_safely")

# Configura as caixas de diálogo com segurança
func setup_dialogue_boxes_safely() -> void:
	print("DEBUG: Configurando caixas de diálogo com segurança...")
	
	# Verifica se já está na árvore
	if not is_inside_tree():
		print("DEBUG: Ainda não está na árvore para configurar caixas de diálogo. Esperando...")
		await tree_entered
	
	# Espera um frame antes de continuar para garantir que tudo está pronto
	await get_tree().process_frame
	
	# Configura as caixas de diálogo
	_setup_dialogue_boxes()
	
	# Avança para a primeira etapa após configuração
	call_deferred("_advance_sequence")

# Configura as caixas de diálogo
func _setup_dialogue_boxes() -> void:
	print("DEBUG: Configurando caixas de diálogo...")
	
	# Verifica se estamos na árvore de cena
	if not is_inside_tree():
		print("DEBUG: ERRO! Nó não está na árvore de cena!")
		call_deferred("setup_dialogue_boxes_safely")
		return
		
	# Verificação de segurança extra
	if not get_tree():
		print("DEBUG: ERRO! get_tree() retornou nulo!")
		await get_tree().process_frame
		call_deferred("_setup_dialogue_boxes")
		return
	
	# Configuração da caixa de diálogo
	if not dialogue_box:
		print("DEBUG: Carregando cena DialogueBox")
		var dialogue_path = "res://scenes/diálogos/caixa de diálogos/DialogueBox.tscn"
		
		if ResourceLoader.exists(dialogue_path):
			var dialogue_scene = load(dialogue_path)
			if dialogue_scene:
				print("DEBUG: DialogueBox carregada com sucesso")
				dialogue_box = dialogue_scene.instantiate()
				
				# Adiciona à árvore com segurança
				if get_tree() and is_inside_tree():
					var root = get_tree().root
					if root:
						root.add_child(dialogue_box)
						dialogue_box.dialogue_line_finished.connect(_on_dialogue_finished)
						print("DEBUG: DialogueBox instanciada e adicionada à árvore")
					else:
						print("DEBUG: ERRO! get_tree().root retornou nulo!")
				else:
					print("DEBUG: ERRO! Nó não está na árvore ou get_tree() é nulo!")
					# Armazenar a caixa de diálogo para adicioná-la depois
					call_deferred("_try_add_dialogue_box")
			else:
				print("DEBUG: ERRO! Não foi possível carregar a cena DialogueBox!")
		else:
			print("DEBUG: ERRO! Caminho da DialogueBox não existe!")
	else:
		print("DEBUG: DialogueBox já existe")
	
	# Configuração da caixa de descrição
	if not description_box:
		print("DEBUG: Carregando cena DescriptionBox")
		var description_path = "res://scenes/diálogos/caixa de descrições/DescriptionBox.tscn"
		
		if ResourceLoader.exists(description_path):
			var description_scene = load(description_path)
			if description_scene:
				print("DEBUG: DescriptionBox carregada com sucesso")
				description_box = description_scene.instantiate()
				
				# Adiciona à árvore com segurança
				if get_tree() and is_inside_tree():
					var root = get_tree().root
					if root:
						root.add_child(description_box)
						description_box.dialogue_line_finished.connect(_on_description_finished)
						print("DEBUG: DescriptionBox instanciada e adicionada à árvore")
					else:
						print("DEBUG: ERRO! get_tree().root retornou nulo!")
				else:
					print("DEBUG: ERRO! Nó não está na árvore ou get_tree() é nulo!")
					# Armazenar a caixa de descrição para adicioná-la depois
					call_deferred("_try_add_description_box")
			else:
				print("DEBUG: ERRO! Não foi possível carregar a cena DescriptionBox!")
		else:
			print("DEBUG: ERRO! Caminho da DescriptionBox não existe!")
	else:
		print("DEBUG: DescriptionBox já existe")

# Tenta adicionar a caixa de diálogo à árvore novamente
func _try_add_dialogue_box() -> void:
	print("DEBUG: Tentando adicionar DialogueBox à árvore novamente")
	
	# Verifica se já está na árvore
	if not is_inside_tree():
		print("DEBUG: Ainda não está na árvore. Agendando nova tentativa...")
		await tree_entered
	
	if dialogue_box and not dialogue_box.is_inside_tree() and get_tree():
		var root = get_tree().root
		if root:
			root.add_child(dialogue_box)
			if not dialogue_box.dialogue_line_finished.is_connected(_on_dialogue_finished):
				dialogue_box.dialogue_line_finished.connect(_on_dialogue_finished)
			print("DEBUG: DialogueBox adicionada à árvore com sucesso na nova tentativa")
		else:
			print("DEBUG: ERRO! get_tree().root ainda é nulo na nova tentativa!")

# Tenta adicionar a caixa de descrição à árvore novamente
func _try_add_description_box() -> void:
	print("DEBUG: Tentando adicionar DescriptionBox à árvore novamente")
	
	# Verifica se já está na árvore
	if not is_inside_tree():
		print("DEBUG: Ainda não está na árvore. Agendando nova tentativa...")
		await tree_entered
	
	if description_box and not description_box.is_inside_tree() and get_tree():
		var root = get_tree().root
		if root:
			root.add_child(description_box)
			if not description_box.dialogue_line_finished.is_connected(_on_dialogue_finished):
				description_box.dialogue_line_finished.connect(_on_dialogue_finished)
			print("DEBUG: DescriptionBox adicionada à árvore com sucesso na nova tentativa")
		else:
			print("DEBUG: ERRO! get_tree().root ainda é nulo na nova tentativa!")

# Funções auxiliares para exibir diálogos e descrições
func _show_dialogue(text: String) -> void:
	if is_instance_valid(description_box):
		description_box.hide_box()  # Esconde a caixa de descrição
	
	if is_instance_valid(dialogue_box) and dialogue_box.has_method("show_line"):
		# Configura a fonte baseada no tipo de diálogo
		if text.begins_with("Jucira:"):
			# Aplica fonte específica da Jucira (KiwiSoda)
			_apply_jucira_font()
		else:
			# Aplica fonte padrão do narrador (Pixellari)
			_apply_narrator_font()
		
		dialogue_box.show_line(text, dialogue_speed)
		_disable_player_movement()  # Desativa movimento do jogador
	else:
		print("DEBUG: ERRO! dialogue_box inválido ou não tem método show_line")
		_advance_sequence()  # Tenta avançar para o próximo passo

func _show_description(text: String) -> void:
	if is_instance_valid(dialogue_box):
		dialogue_box.hide_box()  # Esconde a caixa de diálogo
	
	if is_instance_valid(description_box) and description_box.has_method("show_description"):
		description_box.show_description(text, dialogue_speed)
		_disable_player_movement()  # Desativa movimento do jogador
	else:
		print("DEBUG: ERRO! description_box inválido ou não tem método show_description")
		_advance_sequence()  # Tenta avançar para o próximo passo

# Desativa o movimento do jogador - com todas as verificações possíveis
func _disable_player_movement() -> void:
	print("DEBUG: Tentando desativar movimento do jogador")
	
	var player = _find_player()
	if not player:
		print("DEBUG: ERRO! Jogador não encontrado na cena!")
		return
	
	print("DEBUG: Jogador encontrado: ", player.name)
	
	# Lista de métodos possíveis para desativar o movimento
	var methods_to_try = [
		"set_can_move",
		"disable_movement",
		"lock_movement",
		"freeze_movement",
		"set_movable",
		"set_active"
	]
	
	# Lista de propriedades possíveis para controlar o movimento
	var properties_to_check = [
		"can_move",
		"movement_enabled",
		"is_active",
		"is_movable",
		"enabled",
		"movable",
		"active",
		"locked",
		"frozen"
	]
	
	# Tenta todos os métodos possíveis
	var method_found = false
	for method in methods_to_try:
		if player.has_method(method):
			match method:
				"set_can_move", "set_movable", "set_active":
					player.call(method, false)
				_:  # disable_movement, lock_movement, freeze_movement
					player.call(method)
			print("DEBUG: Movimento do jogador desativado via ", method)
			method_found = true
			break
	
	# Se nenhum método foi encontrado, tenta definir propriedades
	if not method_found:
		var property_found = false
		for prop in properties_to_check:
			if prop in player:
				match prop:
					"can_move", "movement_enabled", "is_active", "is_movable", "enabled", "movable", "active":
						player.set(prop, false)
					"locked", "frozen":
						player.set(prop, true)
				print("DEBUG: Movimento do jogador desativado definindo ", prop)
				property_found = true
				break
		
		# Se nem propriedades foram encontradas, tenta desativar processos
		if not property_found:
			player.set_process_input(false)
			player.set_process_unhandled_input(false)
			player.set_physics_process(false)
			print("DEBUG: Desativado todos os processos do jogador (último recurso)")
			
	# Define processo como desabilitado em último caso
	# Isso é para garantir mesmo que os métodos acima falhem
	if player.has_method("set_process_mode"):
		player.set_process_mode(Node.PROCESS_MODE_DISABLED)
		print("DEBUG: Definido process_mode como DISABLED (garantia adicional)")
	else:
		player.process_mode = Node.PROCESS_MODE_DISABLED
		print("DEBUG: Definido process_mode como DISABLED (propriedade direta)")

# Reativa o movimento do jogador - com todas as verificações possíveis
func _enable_player_movement() -> void:
	print("DEBUG: Tentando reativar movimento do jogador")
	
	var player = _find_player()
	if not player:
		print("DEBUG: ERRO! Jogador não encontrado para reativação!")
		return
		
	print("DEBUG: Jogador encontrado para reativação: ", player.name)
	
	# Lista de métodos possíveis para reativar o movimento
	var methods_to_try = [
		"set_can_move",
		"enable_movement",
		"unlock_movement",
		"unfreeze_movement",
		"set_movable",
		"set_active"
	]
	
	# Lista de propriedades possíveis para controlar o movimento
	var properties_to_check = [
		"can_move",
		"movement_enabled",
		"is_active",
		"is_movable",
		"enabled",
		"movable",
		"active",
		"locked",
		"frozen"
	]
	
	# Tenta todos os métodos possíveis
	var method_found = false
	for method in methods_to_try:
		if player.has_method(method):
			match method:
				"set_can_move", "set_movable", "set_active":
					player.call(method, true)
				_:  # enable_movement, unlock_movement, unfreeze_movement
					player.call(method)
			print("DEBUG: Movimento do jogador reativado via ", method)
			method_found = true
			break
	
	# Se nenhum método foi encontrado, tenta definir propriedades
	if not method_found:
		var property_found = false
		for prop in properties_to_check:
			if prop in player:
				match prop:
					"can_move", "movement_enabled", "is_active", "is_movable", "enabled", "movable", "active":
						player.set(prop, true)
					"locked", "frozen":
						player.set(prop, false)
				print("DEBUG: Movimento do jogador reativado definindo ", prop)
				property_found = true
				break
		
		# Se nem propriedades foram encontradas, tenta reativar processos
		if not property_found:
			player.set_process_input(true)
			player.set_process_unhandled_input(true)
			player.set_physics_process(true)
			print("DEBUG: Reativado todos os processos do jogador (último recurso)")
	
	# Restaura o process_mode para o padrão
	if player.has_method("set_process_mode"):
		player.set_process_mode(Node.PROCESS_MODE_INHERIT)
		print("DEBUG: Restaurado process_mode para INHERIT (garantia adicional)")
	else:
		player.process_mode = Node.PROCESS_MODE_INHERIT
		print("DEBUG: Restaurado process_mode para INHERIT (propriedade direta)")

# Função auxiliar aprimorada para encontrar o jogador na árvore de cena
func _find_player() -> Node:
	print("DEBUG: Procurando o jogador...")
	if not get_tree():
		print("DEBUG: get_tree() é nulo!")
		return null
		
	var root = get_tree().get_root()
	if not root:
		print("DEBUG: get_tree().get_root() é nulo!")
		return null
	
	var player = null
	
	# Método 1: Verificar se existe um nó no grupo "player"
	print("DEBUG: Procurando jogador pelo grupo 'player'...")
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		print("DEBUG: Jogador encontrado através do grupo 'player':", players[0].name)
		return players[0]
	
	# Método 2: Tentando caminhos comuns - verificação mais extensa
	print("DEBUG: Tentando caminhos comuns para o jogador...")
	var possible_paths = [
		"Player",
		"Gameplay/Player",
		"../Player",
		"../../Player",
		"../Gameplay/Player",
		"Game/Gameplay/Player",
		"Game/Player",
		"Jogador",
		"Gameplay/Jogador",
		"../Jogador",
		"../../Jogador",
		"Character",
		"Gameplay/Character",
		"Personagem",
		"Gameplay/Personagem",
		"../PlayerController",
		"/root/Game/Gameplay/Player", 
		"/root/Game/Player",
		"/root/Gameplay/Player",
		"/root/Player",
		"/root/game/Player",
		"PlayerController",
		"../CharacterBody2D"
	]
	
	# Primeira passagem com caminhos absolutos ou relativos
	for path in possible_paths:
		if path.begins_with("/root/"):
			# Caminho absoluto
			player = get_node_or_null(path)
		else:
			# Caminho relativo à raiz
			player = root.get_node_or_null(path)
			
			# Se não encontrou na raiz, tente relativamente a este nó
			if not player:
				player = get_node_or_null(path)
				
		if player:
			print("DEBUG: Jogador encontrado no caminho:", path)
			return player
	
	# Método 3: Procura em cada cena ativa
	print("DEBUG: Procurando em cada cena ativa...")
	for scene in get_tree().get_nodes_in_group("gameplay_scene"):
		for candidate_name in ["Player", "Jogador", "PlayerController", "CharacterBody2D"]:
			player = scene.get_node_or_null(candidate_name)
			if player:
				print("DEBUG: Jogador encontrado em cena de gameplay:", player.name)
				return player
	
	# Método 4: Busca por tipos de nós que comumente são jogadores
	print("DEBUG: Procurando por tipos específicos de nós...")
	var character_bodies = get_tree().get_nodes_in_group("CharacterBody2D")
	if character_bodies.size() > 0:
		for body in character_bodies:
			if body.name.to_lower().contains("player") or \
			   body.name.to_lower().contains("jogador") or \
			   body.name.to_lower() == "character":
				print("DEBUG: Jogador encontrado por tipo de nó:", body.name)
				return body
	
	# Método 5: Busca recursiva pelo nome, grupo ou propriedades específicas
	print("DEBUG: Iniciando busca recursiva pelo jogador...")
	var result = _find_node_recursive(root, "Player")
	if result:
		print("DEBUG: Jogador encontrado por busca recursiva:", result.name)
		return result
	
	# Última tentativa - qualquer CharacterBody2D
	var all_character_bodies = []
	_find_nodes_of_class(root, "CharacterBody2D", all_character_bodies)
	if all_character_bodies.size() > 0:
		print("DEBUG: Usando primeiro CharacterBody2D encontrado como jogador:", all_character_bodies[0].name)
		return all_character_bodies[0]
		
	print("DEBUG: Jogador não encontrado por nenhum método!")
	return null

# Esta declaração foi removida para evitar duplicação com a função abaixo

# Retorna os nomes dos nós filhos para depuração
func _get_children_names(node: Node) -> String:
	var names = []
	for child in node.get_children():
		names.append(child.name)
	return str(names)

# Busca recursiva por um nó com um nome específico
func _find_node_recursive(node: Node, node_name: String) -> Node:
	print("DEBUG: Verificando nó:", node.name)
	
	# Verifica se o nó atual tem o nome procurado ou está no grupo "player"
	# ou se tem características específicas de jogador
	if node.name.to_lower() == node_name.to_lower() or \
	   node.is_in_group("player") or \
	   (node.has_method("is_player") and node.is_player()) or \
	   (node.has_method("set_can_move") and node.name.to_lower().contains("player")) or \
	   (node.has_method("disable_movement") and node.name.to_lower().contains("player")) or \
	   (node.has_property("can_move") and node.name.to_lower().contains("player")) or \
	   (node.has_property("movement_enabled") and node.name.to_lower().contains("player")):
		print("DEBUG: Nó jogador encontrado:", node.name)
		return node
		
	# Verifica cada filho do nó
	for child in node.get_children():
		var result = _find_node_recursive(child, node_name)
		if result:
			return result
	
	return null

# Função para encontrar todos os nós de determinada classe na árvore
func _find_nodes_of_class(node: Node, className: String, result: Array) -> void:
	if node.get_class() == className:
		result.append(node)
	
	for child in node.get_children():
		_find_nodes_of_class(child, className, result)

# Avança para a próxima etapa da sequência
func _advance_sequence() -> void:
	sequence_step += 1
	print("DEBUG: Avançando para o passo", sequence_step, "da sequência")
	
	# Verificar se temos as caixas de diálogo necessárias
	if not dialogue_box or not description_box:
		print("DEBUG: ERRO! Caixas de diálogo não estão configuradas. Tentando configurar novamente...")
		await _setup_dialogue_boxes()
		if not dialogue_box or not description_box:
			print("DEBUG: ERRO! Ainda não foi possível configurar caixas de diálogo. Abortando sequência.")
			_end_sequence()
			return
	
	match sequence_step:
		1: # Telefone toca (descrição)
			print("DEBUG: Passo 1 - Telefone toca")
			_play_phone_ring_sound()
			_show_description("*O telefone começa a tocar*")
		
		2: # Pensamento do jogador sobre atender (diálogo)
			print("DEBUG: Passo 2 - Pensamento sobre atender")
			_show_dialogue("Vamos atender, vai que é importante")
			
		3: # Jucira fala no telefone (diálogo)
			print("DEBUG: Passo 3 - Jucira fala no telefone")
			_show_dialogue("Jucira: Alô? oi meu querido aqui é a Jucira, tem como você vir aqui em casa?")
				
		4: # Jucira explica o problema (diálogo)
			print("DEBUG: Passo 4 - Jucira explica o problema")
			_show_dialogue("Jucira: Estou precisando de ajuda pra organizar minha casa. Vou te dar um dinheirinho se você vier me ajudar")
				
		5: # Pensamento do jogador 1 (diálogo)
			print("DEBUG: Passo 5 - Pensamento do jogador 1")
			_show_dialogue("Bom, você vai aceitar de qualquer forma, quem recusaria o pedido de uma doce senhora.")
				
		6: # Pensamento do jogador 2 (diálogo)
			print("DEBUG: Passo 6 - Pensamento do jogador 2")
			_show_dialogue("E claro, ela tá pagando")
				
		7: # Jucira última fala (diálogo)
			print("DEBUG: Passo 7 - Jucira agradece")
			_show_dialogue("Jucira: Você vai vir? Ótimo, vou estar te esperando, obrigada.")
				
		8: # Telefone desliga (descrição)
			print("DEBUG: Passo 8 - Telefone desliga")
			_play_phone_hangup_sound()
			_show_description("*Telefone desliga*")
				
		9: # Indicação sobre local da casa (diálogo)
			print("DEBUG: Passo 9 - Indicação da casa")
			_show_dialogue("A casa dela fica virando a direita e seguindo pra cima, não tem erro")
				
		10: # Instrução final humorística (diálogo)
			print("DEBUG: Passo 10 - Instrução final")
			_show_dialogue("Agora vá encher o bols... digo, ajudar a doce senhora")
				
		11: # Emoji final (descrição)
			print("DEBUG: Passo 11 - Emoji final")
			_show_description("(●'◡'●)")
			
		12: # Finaliza a sequência
			print("DEBUG: Passo 12 - Finalizando sequência")
			_end_sequence()

# Finaliza a sequência
func _end_sequence() -> void:
	print("DEBUG: Finalizando sequência do telefone da Jucira")
	is_sequence_active = false
	set_process_input(false)
	
	# Esconde as caixas de diálogo com segurança
	if is_instance_valid(dialogue_box):
		dialogue_box.hide_box()
	if is_instance_valid(description_box):
		description_box.hide_box()
	
	# Reativa movimento do jogador ao finalizar
	_enable_player_movement()
	
	# Força a reativação também via call_deferred para garantir
	call_deferred("_delayed_enable_player_movement")
	
	print("DEBUG: Emitindo sinal sequence_finished")
	sequence_finished.emit()
	
# Chamada adiada para garantir que o movimento seja reativado mesmo se houver algum delay
func _delayed_enable_player_movement() -> void:
	await get_tree().process_frame
	_enable_player_movement()

# Processa input durante a sequência
func _input(event: InputEvent) -> void:
	if not is_sequence_active:
		return
	
	# Variável para controlar se o input deve ser processado
	var should_process_input = false
	
	# Detecta teclas de pular diálogo
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_E:
			should_process_input = true
	
	# Detecta cliques/toques na tela para suporte mobile
	elif event is InputEventMouseButton and event.pressed:
		should_process_input = true
		
	# Detecta toques na tela (para dispositivos móveis)
	elif event is InputEventScreenTouch and event.pressed:
		should_process_input = true
	
	# Se qualquer input válido for detectado, processa-o
	if should_process_input:
		get_viewport().set_input_as_handled() # Impede que o input seja processado por outros nodes
		_handle_input_during_sequence()

# Lida com input durante a sequência
func _handle_input_during_sequence() -> void:
	# Se um diálogo estiver em exibição e o efeito de digitação estiver ativo, complete-o
	if is_instance_valid(dialogue_box) and dialogue_box.has_method("is_typewriting") and dialogue_box.is_typewriting():
		if dialogue_box.has_method("complete_typewriter"):
			dialogue_box.complete_typewriter()
		return
	
	# Se uma descrição estiver em exibição e o efeito de digitação estiver ativo, complete-o
	if is_instance_valid(description_box) and description_box.has_method("is_typewriting") and description_box.is_typewriting():
		if description_box.has_method("complete_typewriter"):
			description_box.complete_typewriter()
		return
	
	# Se não estiver em digitação, avança para o próximo passo
	call_deferred("_advance_sequence")

# Callbacks para eventos das caixas de diálogo
func _on_dialogue_finished() -> void:
	print("DEBUG: Diálogo finalizado")
	dialogue_step_completed.emit()

func _on_description_finished() -> void:
	print("DEBUG: Descrição finalizada")
	dialogue_step_completed.emit()

# Efeitos sonoros
func _play_phone_ring_sound() -> void:
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		if audio_manager.has_method("play_sfx"):
			audio_manager.play_sfx("phone_ring", 0.8)
		else:
			print("DEBUG: AudioManager não tem o método play_sfx")

func _play_phone_hangup_sound() -> void:
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		if audio_manager.has_method("play_sfx"):
			audio_manager.play_sfx("phone_hangup", 0.6)
		else:
			print("DEBUG: AudioManager não tem o método play_sfx")

# Aplica a fonte KiwiSoda para os diálogos da Jucira (NPC específico)
func _apply_jucira_font() -> void:
	if not is_instance_valid(dialogue_box):
		print("DEBUG: ERRO! DialogueBox não disponível para aplicar fonte da Jucira")
		return
		
	# Procura o label dentro do dialogue_box - tenta vários caminhos possíveis
	var text_label = dialogue_box.get_node_or_null("BackgroundBox/MarginContainer/TextLabel")
	
	# Se não encontrou pelo caminho padrão, tenta outras alternativas
	if not is_instance_valid(text_label):
		var alternative_paths = [
			"TextLabel",
			"Container/TextLabel", 
			"Panel/TextLabel",
			"DialogContainer/TextLabel",
			"BackgroundBox/TextLabel"
		]
		
		for path in alternative_paths:
			text_label = dialogue_box.get_node_or_null(path)
			if is_instance_valid(text_label):
				break
		
		# Se ainda não encontrou, procura qualquer nó Label no dialogue_box
		if not is_instance_valid(text_label):
			text_label = _find_label_in_node(dialogue_box)
	
	if not is_instance_valid(text_label):
		print("DEBUG: ERRO! TextLabel não encontrado para aplicar fonte da Jucira")
		return
	
	# Carrega a fonte KiwiSoda
	var font_path = "res://assets/fonts/kiwisoda/KiwiSoda.ttf"
	if not ResourceLoader.exists(font_path):
		print("DEBUG: ERRO! Fonte KiwiSoda não encontrada em: " + font_path)
		return
	
	var font = load(font_path)
	if not font:
		print("DEBUG: ERRO! Falha ao carregar a fonte KiwiSoda")
		return
	
	# Aplica a fonte
	var settings = LabelSettings.new()
	if text_label.label_settings:
		settings.font_size = text_label.label_settings.font_size
		settings.font_color = text_label.label_settings.font_color
		settings.outline_size = text_label.label_settings.outline_size if text_label.label_settings.has_method("get_outline_size") else 0
		settings.shadow_size = text_label.label_settings.shadow_size if text_label.label_settings.has_method("get_shadow_size") else 0
	else:
		settings.font_size = 32
		settings.font_color = Color.WHITE
	
	settings.font = font
	text_label.label_settings = settings
	print("DEBUG: Fonte KiwiSoda aplicada aos diálogos da Jucira")

# Aplica a fonte Pixellari para o narrador (fonte padrão)
func _apply_narrator_font() -> void:
	if not is_instance_valid(dialogue_box):
		print("DEBUG: ERRO! DialogueBox não disponível para aplicar fonte do narrador")
		return
		
	# Procura o label dentro do dialogue_box - tenta vários caminhos possíveis
	var text_label = dialogue_box.get_node_or_null("BackgroundBox/MarginContainer/TextLabel")
	
	# Se não encontrou pelo caminho padrão, tenta outras alternativas
	if not is_instance_valid(text_label):
		var alternative_paths = [
			"TextLabel",
			"Container/TextLabel", 
			"Panel/TextLabel",
			"DialogContainer/TextLabel",
			"BackgroundBox/TextLabel"
		]
		
		for path in alternative_paths:
			text_label = dialogue_box.get_node_or_null(path)
			if is_instance_valid(text_label):
				break
		
		# Se ainda não encontrou, procura qualquer nó Label no dialogue_box
		if not is_instance_valid(text_label):
			text_label = _find_label_in_node(dialogue_box)
	
	if not is_instance_valid(text_label):
		print("DEBUG: ERRO! TextLabel não encontrado para aplicar fonte do narrador")
		return
	
	# Carrega a fonte Pixellari (padrão do narrador)
	var font_path = "res://assets/fonts/pixellari/Pixellari.ttf"
	if not ResourceLoader.exists(font_path):
		print("DEBUG: ERRO! Fonte Pixellari não encontrada em: " + font_path)
		return
	
	var font = load(font_path)
	if not font:
		print("DEBUG: ERRO! Falha ao carregar a fonte Pixellari")
		return
	
	# Aplica a fonte
	var settings = LabelSettings.new()
	if text_label.label_settings:
		settings.font_size = text_label.label_settings.font_size
		settings.font_color = text_label.label_settings.font_color
		settings.outline_size = text_label.label_settings.outline_size if text_label.label_settings.has_method("get_outline_size") else 0
		settings.shadow_size = text_label.label_settings.shadow_size if text_label.label_settings.has_method("get_shadow_size") else 0
	else:
		settings.font_size = 32
		settings.font_color = Color.WHITE
	
	settings.font = font
	text_label.label_settings = settings
	print("DEBUG: Fonte Pixellari aplicada ao narrador")

# Função auxiliar para encontrar qualquer Label dentro de um nó
func _find_label_in_node(node: Node) -> Node:
	# Verifica se o próprio nó é um Label
	if node is Label:
		return node
		
	# Procura em todos os filhos
	for child in node.get_children():
		# Verifica se este filho é um Label
		if child is Label:
			return child
			
		# Recursivamente procura nos filhos deste filho
		var label = _find_label_in_node(child)
		if is_instance_valid(label):
			return label
	
	# Nenhum Label encontrado
	return null

# Método para depuração
func _to_string() -> String:
	return "JuciraPhoneSequence(step: %d, active: %s)" % [sequence_step, is_sequence_active]
