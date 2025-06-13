extends Node

# Script para adicionar portas interativas à cena Gameplay
# Este script deve ser adicionado como filho da cena Gameplay.tscn

func _ready() -> void:
	# Adiciona as portas interativas à cena após um pequeno delay para garantir
	# que todos os nós foram carregados corretamente
	call_deferred("setup_interactive_doors")

func setup_interactive_doors() -> void:
	print("Configurando portas interativas na cena Gameplay")
	
	# Adiciona porta para o prólogo (navegação de volta para o quarto inicial)
	add_prologue_door()
	
	# Adiciona outra porta para a área de testes (demo)
	add_test_scene_door()

# Adiciona porta que leva de volta ao quarto inicial (prólogo)
func add_prologue_door() -> void:
	# Cria o nó da porta interativa
	var door = Node.new()
	door.name = "PrologueDoor"
	add_child(door)
	
	# Cria e configura o componente InteractiveDoor
	var interactive_door = InteractiveDoor.new()
	interactive_door.name = "InteractiveDoor"
	interactive_door.target_scene = "res://scenes/prologue/Início/prologue.tscn"
	interactive_door.transition_effect = "fade"
	interactive_door.is_locked = false
	interactive_door.interaction_prompt = "Voltar para o quarto"
	interactive_door.interaction_area_size = Vector2(64, 64)
	
	# Define a posição da porta (ajustar conforme necessário)
	door.position = Vector2(400, 300)
	
	# Adiciona um sprite para representar visualmente a porta
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	
	# Você pode definir uma textura específica para a porta aqui
	# sprite.texture = preload("res://path/to/door_texture.png")
	
	# Adiciona os nós à hierarquia
	door.add_child(interactive_door)
	door.add_child(sprite)
	
	print("Porta para o prólogo adicionada em: ", door.position)

# Adiciona porta para uma cena de teste/debug
func add_test_scene_door() -> void:
	# Cria o nó da porta interativa
	var door = Node.new()
	door.name = "TestSceneDoor"
	add_child(door)
	
	# Cria e configura o componente InteractiveDoor
	var interactive_door = InteractiveDoor.new()
	interactive_door.name = "InteractiveDoor"
	interactive_door.target_scene = "res://scenes/testes/DebugScene.tscn"
	interactive_door.transition_effect = "loading"
	interactive_door.is_locked = false
	interactive_door.interaction_prompt = "Ir para área de testes"
	interactive_door.interaction_area_size = Vector2(64, 64)
	
	# Define a posição da porta (ajustar conforme necessário)
	door.position = Vector2(500, 300)
	
	# Adiciona os nós à hierarquia
	door.add_child(interactive_door)
	
	print("Porta para a cena de testes adicionada em: ", door.position)
