extends InteractiveObject
class_name Jucira

# NPC Jucira - Implementação usando InteractiveObject
# Agora herda de InteractiveObject para funcionar corretamente com o sistema de interação do player

# Propriedades específicas da Jucira
@export var npc_id: String = "jucira"
@export var npc_display_name: String = "Jucira"
@export var auto_look_at_player: bool = true

# Diálogos específicos da Jucira
var dialogues: Dictionary = {}
var current_dialogue_id: String = ""
var is_dialogue_active: bool = false

# Referências aos nós
var sprite: Sprite2D = null
var name_label: Label = null
var npc_manager = null

# Sinais
signal dialogue_started(npc_id: String)
signal dialogue_finished(npc_id: String)
signal interaction_started(npc_id: String)

func _ready() -> void:
	print("Jucira: Inicializando como InteractiveObject...")
	
	# Configurar propriedades de InteractiveObject
	interaction_prompt = "Falar com " + npc_display_name
	interaction_area_size = Vector2(64, 64)
	interaction_cooldown = 1.0  # Evitar múltiplas interações muito rápidas
	
	# Chamar _ready da classe pai (InteractiveObject) - DEVE ser chamado ANTES de outras configurações
	super._ready()
	
	# Conectar ao sinal de interação APÓS o super._ready()
	if not interaction_triggered.is_connected(_on_interaction_triggered):
		interaction_triggered.connect(_on_interaction_triggered)
	
	# Configurar referências aos nós
	_setup_node_references()
	
	# Configurar diálogos específicos da Jucira
	_setup_jucira_dialogues()
	
	# Debug: verificar se os nós foram carregados corretamente
	_debug_node_structure()

# Configurar referências aos nós
func _setup_node_references() -> void:
	# Procurar pelo sprite
	sprite = get_node_or_null("Sprite2D")
	if not sprite:
		print("AVISO: Sprite2D não encontrado na Jucira")
	
	# Configurar label do nome do NPC
	if not name_label:
		name_label = Label.new()
		name_label.name = "NameLabel"
		name_label.text = npc_display_name
		name_label.visible = false
		name_label.position = Vector2(-30, -60)  # Posição acima do sprite
		name_label.add_theme_font_size_override("font_size", 16)
		add_child(name_label)
	
	# Obter referência ao NPCManager
	if not npc_manager:
		npc_manager = get_node_or_null("/root/NPCManager")
		if not npc_manager:
			# Tentar encontrar NPCManager em outros lugares
			var current_scene = get_tree().current_scene
			if current_scene:
				npc_manager = current_scene.get_node_or_null("NPCManager")

# Configurar diálogos específicos da Jucira
func _setup_jucira_dialogues() -> void:
	# Sequência principal de diálogos da Jucira
	add_dialogue("agradecimento", "Obrigada por vir meu querido")
	add_dialogue("pedido_ajuda", "Poderia me ajudar a organizar minha prateleira?")
	add_dialogue("pensamento_jogador", "*bom, ela tá pagando, vai nessa*")
	add_dialogue("instrucoes", "Só ir lá na minha estante de livros ali em cima")

# Adicionar um diálogo ao dicionário
func add_dialogue(dialogue_id: String, text: String) -> void:
	dialogues[dialogue_id] = text
	print("Jucira: Diálogo adicionado - ", dialogue_id, ": ", text)

# Debug: verificar estrutura de nós
func _debug_node_structure() -> void:
	print("=== DEBUG: Estrutura de nós da Jucira ===")
	print("Nome do nó: ", name)
	print("Classe: ", get_class())
	print("Sprite encontrado: ", sprite != null)
	print("Name label criado: ", name_label != null)
	print("NPCManager encontrado: ", npc_manager != null)
	print("Diálogos configurados: ", dialogues.keys())
	print("Área de interação (herdada): ", area_node != null)
	print("==========================================")

# Método chamado quando o InteractiveObject detecta interação
func _on_interaction_triggered(_interactive_object) -> void:
	print("Jucira: Interação detectada via InteractiveObject!")
	start_dialogue_sequence()

# Inicia a sequência de diálogos da Jucira
func start_dialogue_sequence() -> void:
	if is_dialogue_active:
		print("Jucira: Diálogo já está ativo, ignorando nova interação")
		return
	
	print("Jucira: Iniciando sequência de diálogos")
	is_dialogue_active = true
	
	# Emitir sinal de início de interação
	interaction_started.emit(npc_id)
	
	# Começar com o primeiro diálogo
	start_dialogue("agradecimento")

# Inicia um diálogo específico
func start_dialogue(dialogue_id: String) -> void:
	if not dialogues.has(dialogue_id):
		print("Jucira: Diálogo '", dialogue_id, "' não encontrado")
		return
	
	current_dialogue_id = dialogue_id
	var dialogue_text = dialogues[dialogue_id]
	
	print("Jucira: Iniciando diálogo '", dialogue_id, "': ", dialogue_text)
	
	# Buscar caixa de diálogo na cena
	var dialogue_box = _find_dialogue_box()
	if dialogue_box:
		dialogue_box.show_dialogue(dialogue_text)
		
		# Conectar ao sinal de finalização do diálogo se ainda não estiver conectado
		if dialogue_box.has_signal("dialogue_line_finished") and not dialogue_box.dialogue_line_finished.is_connected(_on_dialogue_finished):
			dialogue_box.dialogue_line_finished.connect(_on_dialogue_finished)
	else:
		print("Jucira: Caixa de diálogo não encontrada, finalizando diálogo")
		end_dialogue()
	
	# Emitir sinal
	dialogue_started.emit(npc_id)
	
	# Agendar próximo diálogo
	_schedule_next_dialogue(dialogue_id)

# Agenda o próximo diálogo na sequência
func _schedule_next_dialogue(dialogue_id: String) -> void:
	if dialogue_id == "agradecimento":
		# Aguardar um tempo e continuar para o próximo diálogo
		await get_tree().create_timer(2.5).timeout
		start_dialogue("pedido_ajuda")
	elif dialogue_id == "pedido_ajuda":
		await get_tree().create_timer(3.0).timeout
		start_dialogue("pensamento_jogador")
	elif dialogue_id == "pensamento_jogador":
		await get_tree().create_timer(2.5).timeout
		start_dialogue("instrucoes")
	elif dialogue_id == "instrucoes":
		await get_tree().create_timer(3.0).timeout
		end_dialogue()

# Método para encerrar o diálogo atual
func end_dialogue() -> void:
	is_dialogue_active = false
	current_dialogue_id = ""
	
	# Esconder caixa de diálogo
	var dialogue_box = _find_dialogue_box()
	if dialogue_box:
		dialogue_box.hide_dialogue()
	
	print("Jucira: Diálogo encerrado")
	dialogue_finished.emit(npc_id)

# Método chamado quando uma linha de diálogo é finalizada
func _on_dialogue_finished() -> void:
	print("Jucira: Linha de diálogo finalizada para '", current_dialogue_id, "'")
	# Nota: O agendamento do próximo diálogo já é feito em _schedule_next_dialogue

# Busca pela caixa de diálogo na cena
func _find_dialogue_box():
	# Tentar encontrar em vários locais possíveis
	var possible_paths = [
		"/root/DialogueBox",
		"/root/Game/DialogueBox",
		"/root/Game/Prologue/DialogueBoxUI",
		"/root/Game/Gameplay/DialogueBox"
	]
	
	for path in possible_paths:
		var box = get_node_or_null(path)
		if box:
			return box
	
	# Se não encontrou, procurar recursivamente
	var current_scene = get_tree().current_scene
	if current_scene:
		return _find_node_recursive(current_scene, "DialogueBox", "DialogueBoxUI")
	
	return null

# Busca recursiva por um nó específico
func _find_node_recursive(node: Node, target_name1: String, target_name2: String = "") -> Node:
	if node.name == target_name1 or (target_name2 != "" and node.name == target_name2):
		return node
	
	for child in node.get_children():
		var result = _find_node_recursive(child, target_name1, target_name2)
		if result:
			return result
	
	return null

# Sobrescrever métodos do InteractiveObject para funcionalidade específica

# Sobrescrever register_player_in_range para adicionar comportamento específico da Jucira
func register_player_in_range(player) -> void:
	print("Jucira: Jogador se aproximou")
	
	# Chamar método da classe pai
	super.register_player_in_range(player)
	
	# Mostrar o nome do NPC quando o jogador se aproxima
	if name_label:
		name_label.visible = true
	
	# Olhar para o jogador, se configurado
	if auto_look_at_player:
		_look_at_player(player)

# Sobrescrever unregister_player para adicionar comportamento específico da Jucira
func unregister_player() -> void:
	print("Jucira: Jogador se afastou")
	
	# Chamar método da classe pai
	super.unregister_player()
	
	# Ocultar o nome do NPC
	if name_label:
		name_label.visible = false

# Método para fazer o NPC olhar para o jogador
func _look_at_player(player_body: Node) -> void:
	# Implementação específica da Jucira para olhar para o jogador
	if not sprite or not player_body:
		return
	
	# Como InteractiveObject herda de Node, precisamos obter a posição de forma diferente
	var my_position = Vector2.ZERO
	if sprite:
		my_position = sprite.global_position
	
	var direction = (player_body.global_position - my_position).normalized()
	
	# Virar o sprite baseado na direção (simples flip horizontal)
	if direction.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

# Método de compatibilidade para sistemas antigos
func interact() -> void:
	print("Jucira: Método interact() chamado (compatibilidade)")
	# Não faz nada pois a interação agora é gerenciada pelo InteractiveObject
	# através do sinal interaction_triggered e _on_interaction_triggered

# Métodos de compatibilidade com sistema antigo de NPCs
func get_npc_id() -> String:
	return npc_id

func get_display_name() -> String:
	return npc_display_name

func is_in_dialogue() -> bool:
	return is_dialogue_active
