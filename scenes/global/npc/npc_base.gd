extends Node2D

class_name NPCBase

# Identificador único do NPC no gerenciador de NPCs
@export var npc_id: String = ""
@export var interaction_distance: float = 100.0
@export var auto_look_at_player: bool = true

# Referências a nós
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var interaction_area: Area2D = $Area2D
@onready var name_label: Label = $NameLabel

# Referência ao gerenciador de NPCs (autoload)
var npc_manager = null

# Referência ao DialogueBox (será instanciada conforme necessário)
var dialogue_box = null

# Lista de diálogos que o NPC pode ter
var dialogues: Dictionary = {}

# Sinal emitido quando o jogador interage com o NPC
signal interaction_started(npc_id: String)
signal interaction_ended(npc_id: String)

func _ready() -> void:
	# Verificar se o ID foi configurado
	if npc_id == "":
		push_warning("NPC sem ID configurado!")
		npc_id = "npc_" + str(get_instance_id())
	
	# Obter referência ao gerenciador de NPCs
	npc_manager = get_node("/root/NPCManager")
	
	# Verificar se o NPC está registrado
	if not npc_manager.npc_exists(npc_id):
		push_warning("NPC não registrado no gerenciador: " + npc_id)
	
	# Configurar sprite se disponível
	var npc_sprite = npc_manager.load_npc_sprite(npc_id)
	if npc_sprite and sprite:
		sprite.texture = npc_sprite
	
	# Configurar etiqueta de nome
	if name_label and npc_manager.npc_exists(npc_id):
		name_label.text = npc_manager.get_npc_display_name(npc_id)
		name_label.visible = false  # Inicialmente oculta
	
	# Conectar sinais da área de interação
	if interaction_area:
		if not interaction_area.body_entered.is_connected(_on_body_entered):
			interaction_area.body_entered.connect(_on_body_entered)
		if not interaction_area.body_exited.is_connected(_on_body_exited):
			interaction_area.body_exited.connect(_on_body_exited)

# Método para adicionar um diálogo ao NPC
func add_dialogue(dialogue_id: String, dialogue_text: String, choices: Array = []) -> void:
	dialogues[dialogue_id] = {
		"text": dialogue_text,
		"choices": choices
	}

# Método para obter diálogo pelo ID
func get_dialogue(dialogue_id: String) -> Dictionary:
	if dialogues.has(dialogue_id):
		return dialogues[dialogue_id]
	return {"text": "...", "choices": []}

# Método para iniciar um diálogo específico
func start_dialogue(dialogue_id: String = "") -> void:
	# Se nenhum ID específico foi fornecido, use o primeiro disponível
	if dialogue_id == "" and not dialogues.is_empty():
		dialogue_id = dialogues.keys()[0]
	
	if not dialogues.has(dialogue_id):
		push_warning("Diálogo não encontrado para o NPC: " + npc_id + ", ID de diálogo: " + dialogue_id)
		return
	
	# Verificar se precisamos criar uma nova caixa de diálogo ou usar existente
	if not dialogue_box:
		var dialogue_scene = load("res://scenes/diálogos/caixa de diálogos/DialogueBox.tscn")
		if dialogue_scene:
			dialogue_box = dialogue_scene.instantiate()
			get_tree().get_root().add_child(dialogue_box)
	
	# Configurar estilo da caixa de diálogo baseado no NPC
	_configure_dialogue_box()
	
	# Exibir o diálogo
	var dialogue_data = dialogues[dialogue_id]
	dialogue_box.show_line(dialogue_data.text, 0.03)  # 0.03 é a velocidade de digitação
	
	# Emitir sinal de início de interação
	interaction_started.emit(npc_id)

# Método para encerrar o diálogo atual
func end_dialogue() -> void:
	if dialogue_box:
		dialogue_box.hide_box()
	
	# Emitir sinal de fim de interação
	interaction_ended.emit(npc_id)

# Método para configurar a caixa de diálogo com base nas propriedades do NPC
func _configure_dialogue_box() -> void:
	if not dialogue_box or not npc_manager.npc_exists(npc_id):
		return
	
	# Obter a fonte do NPC
	var font = npc_manager.get_npc_font(npc_id)
	var text_color = npc_manager.get_npc_text_color(npc_id)
	
	# Configurar a fonte na caixa de diálogo se ela tiver o método para isso
	if dialogue_box.has_method("set_dialogue_style"):
		dialogue_box.set_dialogue_style("", text_color, npc_manager.get_npc_data(npc_id).font_size)

# Método para mostrar uma caixa de escolhas
func show_choices(choices: Array) -> void:
	if choices.is_empty():
		return
	
	# Carregar a cena da caixa de escolhas
	var choice_box_scene = load("res://scenes/diálogos/caixa de escolhas/ChoiceDialogueBox.tscn")
	if not choice_box_scene:
		push_warning("Cena ChoiceDialogueBox não encontrada!")
		return
	
	# Instanciar e configurar a caixa de escolhas
	var choice_box = choice_box_scene.instantiate()
	get_tree().get_root().add_child(choice_box)
	
	# Conectar sinal de escolha
	if not choice_box.choice_selected.is_connected(_on_choice_selected):
		choice_box.choice_selected.connect(_on_choice_selected)
	
	# Exibir as escolhas
	choice_box.show_choices("O que você deseja?", choices)

# Método chamado quando o jogador seleciona uma escolha
func _on_choice_selected(choice_index: int) -> void:
	print("NPC ", npc_id, " recebeu escolha: ", choice_index)
	# Implementação específica pode ser adicionada nas subclasses

# Método chamado quando um corpo entra na área de interação
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		# Mostrar o nome do NPC quando o jogador se aproxima
		if name_label:
			name_label.visible = true
		
		# Olhar para o jogador, se configurado
		if auto_look_at_player:
			_look_at_player(body)
		
		# Mostrar dica de interação se o jogador tiver o método para isso
		if body.has_method("show_interaction_hint"):
			body.show_interaction_hint("Falar com " + npc_manager.get_npc_display_name(npc_id))
		
		# Configurar o jogador para interagir com este NPC
		if body.has_method("set_interactive_object"):
			body.set_interactive_object(self)

# Método chamado quando um corpo sai da área de interação
func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		# Ocultar o nome do NPC
		if name_label:
			name_label.visible = false
		
		# Ocultar dica de interação se o jogador tiver o método para isso
		if body.has_method("hide_interaction_hint"):
			body.hide_interaction_hint()
		
		# Remover referência de objeto interativo
		if body.has_method("clear_interactive_object"):
			body.clear_interactive_object()

# Método para fazer o NPC olhar para o jogador
func _look_at_player(player_body: Node) -> void:
	# Implemente aqui a lógica para fazer o NPC virar para o jogador
	# Este método pode ser sobrescrito em subclasses para implementações específicas
	pass

# Método chamado quando o jogador interage com o NPC
func interact(player) -> void:
	# Verificar se tem diálogos registrados
	if dialogues.is_empty():
		print("NPC ", npc_id, " não tem diálogos configurados.")
		return
	
	# Iniciar o primeiro diálogo disponível
	start_dialogue()
	
	# Tocar som de diálogo personalizado do NPC
	var random_pitch = randf_range(0.95, 1.05)  # Pequena variação para parecer mais natural
	npc_manager.play_npc_dialogue_sound(npc_id, 0.2, random_pitch)
