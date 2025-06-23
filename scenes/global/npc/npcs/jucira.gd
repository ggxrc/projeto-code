extends NPCBase

# NPC Jucira - Personagem do jogo
# Este script contém os comportamentos específicos e diálogos da Jucira

func _ready() -> void:
	# Chamar o _ready() da classe pai para inicialização básica
	super()
	
	# Adicionar diálogos específicos da Jucira
	add_dialogue("saudacao", "Olá, visitante! Bem-vindo à nossa vila.")
	add_dialogue("apresentacao", "Meu nome é Jucira. Eu moro aqui há mais de 30 anos.")
	add_dialogue("historia", "Esta vila tem muitas histórias interessantes. Você sabia que antigamente isto era apenas um pequeno porto de pescadores?")
	
	# Diálogo com opções
	var escolhas = [
		"Conte-me mais sobre a vila",
		"Você conhece algum lugar interessante por aqui?",
		"Preciso ir agora, até logo!"
	]
	add_dialogue("conversa", "Em que posso ajudar você?", escolhas)

# Sobrescrever o método de resposta a escolhas
func _on_choice_selected(choice_index: int) -> void:
	match choice_index:
		0:
			# Escolha: Conte-me mais sobre a vila
			add_dialogue("sobre_vila", "A vila foi fundada há cerca de 100 anos. Começamos como um porto pesqueiro, mas com o tempo outras atividades surgiram. Hoje temos uma pequena comunidade bem unida!")
			start_dialogue("sobre_vila")
		1:
			# Escolha: Você conhece algum lugar interessante por aqui?
			add_dialogue("lugares", "Claro! Você deveria visitar a praça central, tem uma árvore centenária linda. A casa do prefeito também é um lugar histórico. E não deixe de passar na loja do seu Zé, ele vende os melhores doces da região!")
			start_dialogue("lugares")
		2:
			# Escolha: Preciso ir agora, até logo!
			add_dialogue("despedida", "Tudo bem! Foi um prazer conversar com você. Volte quando quiser!")
			start_dialogue("despedida")
			# Após mostrar a despedida, encerrar o diálogo
			await get_tree().create_timer(2.0).timeout
			end_dialogue()

# Sobrescrever o método de interação para comportamento personalizado
func interact(player) -> void:
	print("Jucira: Interagindo com o jogador")
	
	# Chamar método da classe pai para iniciar diálogo normalmente
	super(player)
	
	# Som de diálogo personalizado com pitch específico para Jucira
	npc_manager.play_npc_dialogue_sound(npc_id, 0.3, 1.15)
