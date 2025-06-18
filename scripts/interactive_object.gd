extends Node
class_name InteractiveObject

# Classe base para todos os objetos interagíveis no jogo
# Será estendida por tipos específicos como portas, alavancas, etc.

# Sinal emitido quando o jogador interage com este objeto
signal interaction_triggered(object)

# Propriedades configuráveis
@export var interaction_prompt: String = "Interagir"  # Texto exibido ao jogador
@export var interaction_enabled: bool = true          # Se o objeto pode ser interagido
@export var interaction_cooldown: float = 0.5         # Tempo mínimo entre interações
@export var interaction_area_size: Vector2 = Vector2(40, 40)  # Tamanho da área de interação

# Controle interno
var last_interaction_time: float = 0.0
var player_in_range: bool = false
var player_node = null
var area_node: Area2D = null

func _ready() -> void:
	# Conecta sinais relevantes se o nó pai tiver um método _on_interaction
	if get_parent() and get_parent().has_method("_on_interaction"):
		interaction_triggered.connect(get_parent()._on_interaction)
		
	# Configurar área de interação para detectar o jogador
	_setup_interaction_area()
		
# Configura a área de interação para detectar quando o jogador se aproxima
func _setup_interaction_area() -> void:
	# Verifica se já existe uma área de interação
	if has_node("InteractionArea"):
		area_node = get_node("InteractionArea")
		return
		
	# Cria a área de interação
	area_node = Area2D.new()
	area_node.name = "InteractionArea"
	
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
	print("InteractiveObject: Área de interação configurada para ", name)
	
# Chamado quando um corpo entra na área de interação
func _on_body_entered(body: Node) -> void:
	# Debug: mostrar qual corpo entrou
	print("Corpo entrou na área: ", body.name, ", tipo: ", body.get_class())
	
	# Verifica se é o jogador
	if _is_player(body):
		register_player_in_range(body)
		print("Jogador próximo a ", name, " - Interação disponível")
	else:
		print("Corpo não é jogador, ignorando")

# Chamado quando um corpo sai da área de interação
func _on_body_exited(body: Node) -> void:
	# Verifica se é o jogador
	if _is_player(body):
		unregister_player()
		print("Jogador saiu da área de ", name)
		
# Função auxiliar para verificar se o nó é o jogador
func _is_player(node: Node) -> bool:
	# Imprimir informações para debug
	print("Verificando se nó é jogador: ", node.name)
	
	# Verificar se está no grupo "player"
	if node.has_method("is_in_group") and node.is_in_group("player"):
		print("Nó reconhecido como jogador pelo grupo 'player'")
		return true
	
	# Verificar pelo nome
	if node.name == "Player" or node.name == "Body" or node.get_parent().name == "Player":
		print("Nó reconhecido como jogador pelo nome: ", node.name)
		return true
	
	return false

# Esta função é chamada pelo player quando a interação ocorre
func interact() -> void:
	if not interaction_enabled:
		return
		
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_interaction_time < interaction_cooldown:
		return
		
	last_interaction_time = current_time
	print("Interação com objeto: ", self.name)
	
	# Emite o sinal para que outros objetos possam responder
	interaction_triggered.emit(self)

# Obtém o texto de prompt que deve ser exibido ao jogador
func get_interaction_prompt() -> String:
	return interaction_prompt
	
# Define se este objeto pode ser interagido no momento
func set_interaction_enabled(enabled: bool) -> void:
	interaction_enabled = enabled
	
# Funções para registrar a presença do jogador
func register_player_in_range(player) -> void:
	player_in_range = true
	player_node = player
	
	# Notifica o jogador de que ele pode interagir com este objeto
	if player_node and player_node.has_method("atualizar_botao_interacao"):
		player_node.objeto_interagivel_atual = self
		player_node.atualizar_botao_interacao()
	
func unregister_player() -> void:
	# Desativa a interação quando o jogador sai da área
	if player_node and player_node.objeto_interagivel_atual == self:
		player_node.objeto_interagivel_atual = null
		if player_node.has_method("atualizar_botao_interacao"):
			player_node.atualizar_botao_interacao()
			
	player_in_range = false
	player_node = null
