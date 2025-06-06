extends Node2D

# Este script adiciona colisão para o sofá
# Para corrigir o problema de posicionamento dos personagens no sofá

func _ready():
	# Verificar se já existe uma colisão para não duplicar
	if has_node("CouchCollision"):
		return
	
	# Criar um corpo estático para o sofá
	var static_body = StaticBody2D.new()
	static_body.name = "CouchCollision"
	
	# Criar a forma de colisão
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	
	# Ajustar o tamanho da colisão para o sofá
	# Estas dimensões podem precisar ser ajustadas com base no tamanho exato do sprite do sofá
	shape.size = Vector2(60, 30) # Ajustar estes valores conforme necessário
	collision.shape = shape
	
	# Posicionar a colisão no centro do sofá (ajustar conforme necessário)
	collision.position = Vector2(0, -5) # Ajustar estes valores conforme necessário
	
	# Adicionar a colisão ao corpo estático
	static_body.add_child(collision)
	
	# Adicionar o corpo estático à cena
	add_child(static_body)
	
	print("Colisão do sofá adicionada com sucesso!")
