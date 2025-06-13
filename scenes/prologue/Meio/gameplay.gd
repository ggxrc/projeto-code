extends Node

# Script principal para a cena Gameplay
# Este script controla a lógica principal da cena de gameplay

func _ready() -> void:
	print("Cena Gameplay carregada com sucesso!")
	
	# Adiciona o script de gerenciamento de portas
	var door_manager = Node.new()
	door_manager.name = "DoorManager"
	door_manager.set_script(load("res://scenes/prologue/Meio/gameplay_doors.gd"))
	add_child(door_manager)
	
	# Configura quaisquer outras inicializações necessárias
	_setup_scene()

func _setup_scene() -> void:
	# Encontra o jogador na cena
	var player = get_node_or_null("Player")
	if not player:
		# Se o jogador não estiver presente, procurar em outro lugar ou adicionar
		player = find_player_in_scene()
		
	if player:
		print("Jogador encontrado na cena Gameplay")
	else:
		printerr("Jogador não encontrado na cena Gameplay!")

# Função auxiliar para encontrar o jogador em qualquer lugar da cena
func find_player_in_scene() -> Node:
	# Procura recursivamente em todos os nós da cena
	return _find_player_recursive(self)

# Função recursiva para procurar o jogador
func _find_player_recursive(node: Node) -> Node:
	if node.name == "Player":
		return node
		
	for child in node.get_children():
		var result = _find_player_recursive(child)
		if result:
			return result
			
	return null
