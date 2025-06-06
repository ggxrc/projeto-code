extends Node

# Script para gerenciar a colisão do sofá
# Desativa a colisão quando o jogador está sobre o sofá
# Reativa a colisão quando o jogador sai

var sofa_layer
var player_body
var player_on_sofa = false

func _ready():
	# Esperar um frame para garantir que todos os nós estão prontos
	await get_tree().process_frame
	
	# Tenta encontrar o nó do sofá
	var root = get_tree().root
	sofa_layer = find_sofa_layer(root)
	
	if sofa_layer:
		print("Sofa Layer encontrada: ", sofa_layer.name)
		# Criar uma área de detecção para o sofá
		setup_sofa_detection_area()
	else:
		printerr("Não foi possível encontrar a camada do sofá!")
	
	# Encontra o jogador
	player_body = get_player()
	if not player_body:
		printerr("Não foi possível encontrar o jogador!")

# Encontra a camada do sofá no TileMap
func find_sofa_layer(node):
	if node.name == "Sofa" and node is TileMapLayer:
		return node
	
	for child in node.get_children():
		var result = find_sofa_layer(child)
		if result:
			return result
	
	return null

# Encontra o nó do jogador
func get_player():
	var root = get_tree().root
	return find_player_node(root)

func find_player_node(node):
	if node.name == "Player" or node.name == "Body" and node is CharacterBody2D:
		return node
	
	for child in node.get_children():
		var result = find_player_node(child)
		if result:
			return result
	
	return null

# Configura uma área para detectar o jogador entrando/saindo do sofá
func setup_sofa_detection_area():
	# Criar um nó de área
	var area = Area2D.new()
	area.name = "SofaDetectionArea"
	
	# Criar a forma de colisão para a área
	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	
	# Ajustar o tamanho da área para o sofá
	shape.size = Vector2(120, 40)  # Ajuste conforme o tamanho do seu sofá
	collision_shape.shape = shape
	
	# Adicionar a forma à área
	area.add_child(collision_shape)
	
	# Conectar os sinais para detectar entrada/saída
	area.body_entered.connect(_on_sofa_area_body_entered)
	area.body_exited.connect(_on_sofa_area_body_exited)
	
	# Adicionar a área ao nó pai do sofá
	if sofa_layer and sofa_layer.get_parent():
		sofa_layer.get_parent().add_child(area)
		
		# Posicionar a área no mesmo local do sofá
		area.position = sofa_layer.position
		print("Área de detecção do sofá configurada com sucesso!")
	
# Quando o jogador entra no sofá
func _on_sofa_area_body_entered(body):
	# Verifica se o corpo é o jogador
	if body == player_body or (player_body and body.is_in_group("player")):
		print("Jogador entrou no sofá")
		player_on_sofa = true
		
		# Desativa a colisão do sofá
		if sofa_layer and sofa_layer.get("collision_enabled") != null:
			sofa_layer.set("collision_enabled", false)
			print("Colisão do sofá desativada")

# Quando o jogador sai do sofá
func _on_sofa_area_body_exited(body):
	# Verifica se o corpo é o jogador
	if body == player_body or (player_body and body.is_in_group("player")):
		print("Jogador saiu do sofá")
		player_on_sofa = false
		
		# Reativa a colisão do sofá
		if sofa_layer and sofa_layer.get("collision_enabled") != null:
			sofa_layer.set("collision_enabled", true)
			print("Colisão do sofá reativada")
