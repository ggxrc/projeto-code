extends Node

# Este autoload fornece funções de utilidade para verificar estados globais do jogo
# Use-o para verificações de estado que precisam ser acessíveis de qualquer lugar

# Verifica se qualquer sistema de diálogo está ativo no momento
func is_dialogue_active() -> bool:
	# Procura pelos nós de diálogo conhecidos na cena
	var root = get_tree().root
	
	# Verifica se DialogueBoxUI está visível
	var dialogue_box = find_node_by_name_recursive(root, "DialogueBoxUI")
	if dialogue_box and dialogue_box is CanvasLayer and dialogue_box.visible:
		return true
	
	# Verifica se ChoiceDialogueBox está visível
	var choice_box = find_node_by_name_recursive(root, "ChoiceDialogueBox")
	if choice_box and choice_box is CanvasLayer and choice_box.visible:
		return true
		
	# Verifica se DescriptionBoxUI está visível
	var desc_box = find_node_by_name_recursive(root, "DescriptionBoxUI")
	if desc_box and desc_box is CanvasLayer and desc_box.visible:
		return true
	
	# Em caso de cenas específicas, verifica a variável dialogue_active
	var prologue = find_node_by_name_recursive(root, "Prologue")
	if prologue and prologue.get("dialogue_active") == true:
		return true
		
	return false

# Função recursiva para encontrar um nó na árvore de cena
func find_node_by_name_recursive(node: Node, name: String) -> Node:
	if node.name == name:
		return node
		
	for child in node.get_children():
		var result = find_node_by_name_recursive(child, name)
		if result:
			return result
			
	return null
