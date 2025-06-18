extends Node2D

func _ready():
	# Criar um objeto interativo simples para teste
	var obj = InteractiveObject.new()
	obj.name = "ObjetoTesteInteracao"
	obj.interaction_prompt = "Testar Interação"
	obj.interaction_area_size = Vector2(200, 200)  # Área maior para facilitar testes
	
	# Posicionar no centro da tela ou próximo ao jogador
	var viewport_size = get_viewport_rect().size
	obj.position = Vector2(viewport_size.x / 2, viewport_size.y / 2)
	
	add_child(obj)
	print("Objeto de teste de interação criado em: ", obj.position)
