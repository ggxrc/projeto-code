extends Node

# Script para adicionar portas interativas à cena Prologue
# Este script deve ser adicionado como filho da cena prologue.tscn

func _ready() -> void:
	# Adiciona as portas interativas à cena após um pequeno delay para garantir
	# que todos os nós foram carregados corretamente
	call_deferred("setup_interactive_doors")

func setup_interactive_doors() -> void:
	print("Configurando porta interativa na cena do Prólogo")
	
	# Tenta localizar a porta existente para colocar a porta interativa lá
	var door_node = get_node_or_null("QuartoCasa/Porta")
	if not door_node:
		printerr("Nó da porta não encontrado em QuartoCasa/Porta!")
		return
	
	print("Porta encontrada, adicionando componente de porta interativa")
	
	# Cria e configura o componente InteractiveDoor
	var interactive_door = InteractiveDoor.new()
	interactive_door.name = "InteractiveDoor"
	interactive_door.target_scene = "res://scenes/prologue/Meio/Gameplay.tscn"
	interactive_door.transition_effect = "fade"
	interactive_door.is_locked = false
	interactive_door.interaction_prompt = "Sair do quarto"
	interactive_door.interaction_area_size = Vector2(64, 64)
	
	# Adiciona a porta interativa à porta existente
	door_node.add_child(interactive_door)
	
	# Configura a posição da área de interação com base na posição da porta
	# A posição da área já será relativa à porta, então não precisa de ajustes grandes
	interactive_door.position = Vector2.ZERO
	
	print("Porta interativa configurada com sucesso em: ", door_node.get_path())

# Função para mostrar uma mensagem de depuração
func _debug_position_of_door() -> void:
	var door_node = get_node_or_null("QuartoCasa/Porta")
	if door_node:
		print("Posição da porta: ", door_node.global_position)
		print("Posição do jogador: ", get_node_or_null("Player").global_position if get_node_or_null("Player") else "Jogador não encontrado")
