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

# Controle interno
var last_interaction_time: float = 0.0
var player_in_range: bool = false
var player_node = null

func _ready() -> void:
	# Conecta sinais relevantes se o nó pai tiver um método _on_interaction
	if get_parent() and get_parent().has_method("_on_interaction"):
		interaction_triggered.connect(get_parent()._on_interaction)

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
