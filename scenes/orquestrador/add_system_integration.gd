@tool
extends EditorScript

# Este script adiciona o SystemIntegrationAdapter à cena Game.tscn
# Para usar: Abra o Godot Editor, vá para Editor > Run EditorScript,
# selecione este script, e clique em "Run"

func _run():
	print("Iniciando integração do sistema modular...")
	
	# Carregar a cena Game.tscn
	var game_scene_path = "res://scenes/orquestrador/Game.tscn"
	var game_scene = load(game_scene_path)
	
	if not game_scene:
		printerr("Erro: Não foi possível carregar a cena Game.tscn")
		return
	
	# Instanciar a cena para modificá-la
	var game_instance = game_scene.instantiate()
	
	# Verificar se o SystemIntegrationAdapter já existe
	var adapter = game_instance.get_node_or_null("SystemIntegrationAdapter")
	if adapter:
		print("SystemIntegrationAdapter já existe na cena.")
		game_instance.free()
		return
	
	print("Adicionando SystemIntegrationAdapter...")
	
	# Criar o nó SystemIntegrationAdapter
	var integration_adapter = Node.new()
	integration_adapter.name = "SystemIntegrationAdapter"
	
	# Obter o script
	var adapter_script = load("res://systems/SystemIntegrationAdapter.gd")
	if not adapter_script:
		printerr("Erro: Não foi possível carregar o script SystemIntegrationAdapter.gd")
		game_instance.free()
		return
	
	# Anexar o script ao nó
	integration_adapter.set_script(adapter_script)
	
	# Adicionar o nó à cena
	game_instance.add_child(integration_adapter)
	integration_adapter.owner = game_instance
	
	print("Verificando se precisamos adicionar o SceneContainer...")
	
	# Verificar se já existe um SceneContainer
	var scene_container = game_instance.get_node_or_null("SceneContainer")
	if not scene_container:
		print("Adicionando SceneContainer...")
		scene_container = Node.new()
		scene_container.name = "SceneContainer"
		game_instance.add_child(scene_container)
		scene_container.owner = game_instance
	
	# Salvar a cena modificada
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(game_instance)
	
	if result != OK:
		printerr("Erro ao empacotar a cena:", result)
		game_instance.free()
		return
	
	result = ResourceSaver.save(packed_scene, game_scene_path)
	
	if result != OK:
		printerr("Erro ao salvar a cena:", result)
		game_instance.free()
		return
	
	print("SystemIntegrationAdapter adicionado com sucesso à cena Game.tscn!")
	print("A nova estrutura está pronta para uso.")
	game_instance.free()
