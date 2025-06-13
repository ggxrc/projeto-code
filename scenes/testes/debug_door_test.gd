extends Node

# Script de teste para o sistema de portas interativas
# Adicione este script à cena DebugScene.tscn para demonstrar o funcionamento

func _ready() -> void:
	print("Cena de teste carregada! Demonstrando sistema de portas interativas")
	
	# Adiciona uma porta de volta para a cena de gameplay
	add_test_door()
	
	# Configura indicadores visuais para facilitar o teste
	setup_test_interface()

func add_test_door() -> void:
	# Cria o nó da porta
	var door = Node2D.new()
	door.name = "TestDoor"
	door.position = Vector2(400, 300)
	add_child(door)
	
	# Cria um sprite para visualizar a porta
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	door.add_child(sprite)
	
	# Adiciona um retângulo colorido como visual temporário
	var rect_texture = create_rect_texture(Color(0.2, 0.6, 1.0, 0.8))
	sprite.texture = rect_texture
	
	# Cria o componente de porta interativa
	var interactive_door = InteractiveDoor.new()
	interactive_door.name = "InteractiveDoor"
	interactive_door.target_scene = "res://scenes/prologue/Meio/Gameplay.tscn"
	interactive_door.transition_effect = "fade"
	interactive_door.interaction_prompt = "Voltar para Gameplay"
	interactive_door.interaction_area_size = Vector2(100, 100)
	door.add_child(interactive_door)
	
	print("Porta de teste adicionada em: ", door.position)

# Cria uma textura retangular para representar visualmente a porta
func create_rect_texture(color: Color) -> ImageTexture:
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(color)
	
	# Desenha uma borda
	for x in range(64):
		for y in range(64):
			if x < 2 or x > 61 or y < 2 or y > 61:
				image.set_pixel(x, y, Color(0, 0, 0, 1))
	
	var texture = ImageTexture.create_from_image(image)
	return texture

# Adiciona informações visuais para testar o sistema
func setup_test_interface() -> void:
	# Adiciona uma label informativa
	var label = Label.new()
	label.text = "Teste do Sistema de Portas Interativas\n\n" + \
				 "1. Aproxime-se da porta azul\n" + \
				 "2. Pressione E para interagir ou use o botão na tela\n" + \
				 "3. A porta levará de volta à cena Gameplay"
	
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	label.position = Vector2(100, 50)
	label.size = Vector2(600, 200)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color.WHITE)
	
	# Adiciona uma sombra para melhor contraste
	var shadow = Label.new()
	shadow.text = label.text
	shadow.horizontal_alignment = label.horizontal_alignment
	shadow.vertical_alignment = label.vertical_alignment
	shadow.position = Vector2(102, 52)
	shadow.size = label.size
	shadow.add_theme_font_size_override("font_size", 18)
	shadow.add_theme_color_override("font_color", Color(0, 0, 0, 0.7))
	
	# Adiciona à cena
	add_child(shadow)
	add_child(label)
	
	print("Interface de teste configurada")
