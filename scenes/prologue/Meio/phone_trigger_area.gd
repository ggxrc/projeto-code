extends Area2D

# Este script detecta quando o jogador sai da área e inicia a sequência do telefone de Jucira
# Aplique este script diretamente à Area2D existente na cena Gameplay.tscn

signal player_exited_area

func _ready() -> void:
	print("DEBUG: Área de gatilho do telefone inicializando...")
	
	# Verifica camadas de colisão
	print("DEBUG: Camada de colisão da área:", collision_layer)
	print("DEBUG: Máscara de colisão da área:", collision_mask)
	
	# Conexão explícita do sinal body_exited
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)
		print("DEBUG: Sinal body_exited conectado com sucesso")
	
	# Verifica se há corpos já dentro da área
	var bodies_in_area = get_overlapping_bodies()
	print("DEBUG: Corpos já dentro da área:", bodies_in_area.size())
	for body in bodies_in_area:
		print("DEBUG: - Corpo na área:", body.name)
		if body.is_in_group("player"):
			print("DEBUG: - Jogador detectado na área!")
	
	print("DEBUG: Área de gatilho do telefone inicializada")

func _on_body_exited(body: Node) -> void:
	print("DEBUG: Corpo saiu da área:", body.name)
	
	# Verifica se quem saiu é o jogador
	if body.is_in_group("player"):
		print("DEBUG: Jogador saiu da área de gatilho do telefone!")
		player_exited_area.emit()
		print("DEBUG: Sinal player_exited_area emitido")
				# Procura o nó de gameplay na árvore de cena (não apenas o pai direto)
		var gameplay_node = _find_gameplay_node()
		print("DEBUG: Nó de gameplay encontrado:", gameplay_node.name if gameplay_node else "nenhum")
		
		if gameplay_node:
			print("DEBUG: O nó tem o método iniciar_sequencia_telefone?", gameplay_node.has_method("iniciar_sequencia_telefone"))
			print("DEBUG: Estado sequencia_telefone_iniciada:", gameplay_node.get("sequencia_telefone_iniciada") if gameplay_node.get("sequencia_telefone_iniciada") != null else "propriedade não encontrada")
		
		if gameplay_node and gameplay_node.has_method("iniciar_sequencia_telefone") and not gameplay_node.sequencia_telefone_iniciada:
			print("DEBUG: Chamando iniciar_sequencia_telefone()")
			gameplay_node.iniciar_sequencia_telefone()
		else:
			print("DEBUG: Não foi possível iniciar a sequência do telefone")
			
# Encontra o nó que tem o script gameplay.gd na árvore de cena
func _find_gameplay_node() -> Node:
	# Começa do nó raiz e busca recursivamente
	var root = get_tree().get_root()
	
	print("DEBUG: Procurando nó com script gameplay.gd")
	
	# Tenta encontrar um nó com o script gameplay.gd
	# Primeiro verifica o caminho com capitalização exata
	var node = _search_node_with_script(root, "res://scenes/prologue/Meio/gameplay.gd")
	
	# Se não encontrar, tenta com primeira letra maiúscula (Gameplay.gd)
	if not node:
		print("DEBUG: Tentando encontrar com Game maiúsculo")
		node = _search_node_with_script(root, "res://scenes/prologue/Meio/Gameplay.gd")
	
	# Verifica também por nome do nó se não encontrar pelo script
	if not node:
		print("DEBUG: Procurando por nome de nó 'Gameplay'")
		node = _find_node_by_name(root, "Gameplay")
	
	return node

# Busca recursiva por um nó com um script específico
func _search_node_with_script(node: Node, script_path: String) -> Node:
	# Verifica se o nó atual tem o script
	if node.get_script() and node.get_script().resource_path == script_path:
		print("DEBUG: Nó com script gameplay.gd encontrado:", node.name)
		return node
	
	# Verifica cada filho do nó
	for child in node.get_children():
		var result = _search_node_with_script(child, script_path)
		if result:
			return result
	
	return null

# Busca recursiva por um nó com um nome específico
func _find_node_by_name(node: Node, node_name: String) -> Node:
	# Verifica se o nó atual tem o nome procurado
	if node.name == node_name:
		print("DEBUG: Nó com nome", node_name, "encontrado")
		return node
	
	# Verifica cada filho do nó
	for child in node.get_children():
		var result = _find_node_by_name(child, node_name)
		if result:
			return result
	
	return null
