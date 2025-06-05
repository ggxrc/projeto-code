extends Node 

# Constantes para modo de depuração
const DEBUG_DIALOGUE = true # Ative para ver logs detalhados do fluxo de diálogo

# Constantes para identificar os caminhos
const PATH_STANDARD = 0 # Caminho padrão (amarelo)
const PATH_BLUE = 1     # Caminho alternativo (azul)

@onready var tela_inicial: Control = $TelaInicial
@onready var dialogue_box = $DialogueBoxUI
@onready var choice_dialogue_box = $ChoiceDialogueBox
@onready var description_box = $DescriptionBoxUI
@onready var click_indicator = $ClickIndicator if has_node("ClickIndicator") else null

# Variáveis para controlar a espera por clique do usuário
var waiting_for_input = false
var text_displayed_completely = false

# Rastreamento do caminho do usuário
var current_path = PATH_STANDARD

var linhas_dialogo: Array[String] = [
	"Seja bem vindo(a), vejo que você é novo por aqui.",
	"Você pode achar que o começo é fácil, mas você sabe o que fazer?"
]
var indice_linha_atual: int = 0
var game_manager: Node = null

# Estados do diálogo
enum DialogueState {
	INTRO,
	FIRST_CHOICE,
	SECOND_CHOICE,
	BLUE_PATH,
	BLUE_PATH_CONTINUATION, # Após escolha no caminho azul
	YELLOW_PATH,
	CONCLUSION
}

# Estado atual do diálogo
var current_state = DialogueState.INTRO
var current_text_index = 0
var selected_option = -1
var dialogue_active = false

# Textos do roteiro
var intro_texts = [
	"*Protagonista dormindo*", # Texto de contexto, não será exibido
	"Aí está nosso faz-tudo, em sua confortável cama.",
	"...",
	"ou deveria ser uma cama... o importante é o conforto",
	"Ele está dormindo, o que você vai fazer?"
]

var original_first_choices = [
	"a) acordar",
	"b) levantar",
	"c) abrir o olho",
	"d) sair da cama"
]

# Versão que será modificada quando o jogador fizer escolhas erradas
var first_choices = original_first_choices.duplicate()

# Rastreia quais opções já foram tentadas e estão incorretas
var incorrect_first_choices = []

var after_first_choice_texts = {
	0: "ótimo, está indo no caminho certo", # acordar
	1: "vai levantar dormindo?", # levantar
	2: "vai abrir o olho dormindo?", # abrir o olho
	3: "que eu saiba ele não é sonâmbulo" # sair da cama
}

var original_second_choices = [
	"b) levantar",
	"c) abrir o olho", 
	"d) sair da cama"
]

# Versão que será modificada quando o jogador fizer escolhas erradas
var second_choices = original_second_choices.duplicate()

# Rastreia quais opções já foram tentadas e estão incorretas
var incorrect_second_choices = []

var after_second_choice_texts = {
	0: "isso mesmo", # levantar
	1: "isso mesmo", # abrir o olho
	2: "vai sair deitado?" # sair da cama
}

var blue_path_texts = [
	"*Protagonista cai da cama*", # Texto de contexto, não será exibido
	"Muito bem, você esbagaçou ele no chão, mas, tecnicamente funciona... Então, o que vem agora?"
]

var blue_path_choices = [
	"a) levantar",
	"b) abrir o olho"
]

var blue_path_responses = {
	0: "Maravilha, você levantou, mas por que até agora você não abriu o olho?", # levantar
	1: "De que adianta abrir o olho se você ainda tá no chão?" # abrir o olho
}

# Textos adicionais após a escolha no caminho azul
var blue_path_levantar_texts = [
	"*Protagonista se levanta do chão*", # Texto de contexto, não será exibido
	"Agora você precisa abrir os olhos para completar o algoritmo.",
	"*Protagonista abre os olhos*", # Texto de contexto, não será exibido
	"Ótimo! O algoritmo foi concluído, mesmo que de um jeito... diferente."
]

var blue_path_olho_texts = [
	"*Protagonista abre os olhos ainda no chão*", # Texto de contexto, não será exibido
	"Agora você precisa levantar para completar o algoritmo.",
	"*Protagonista se levanta do chão*", # Texto de contexto, não será exibido
	"Ótimo! O algoritmo foi concluído, mesmo que de um jeito... diferente."
]

# Variável para controlar qual caminho de resposta azul será usado
var blue_path_continuation_texts = [] # Será definida dinamicamente

# Textos para quando o usuário escolhe "levantar" (opção 0)
var yellow_path_levantar_texts = [
	"Agora que você levantou, só sobra abrir o olho.",
	"*Protagonista abre os olhos*", # Texto de contexto, não será exibido
	"*Protagonista agora em pé com os olhos abertos*", # Texto de contexto, não será exibido
	"Pronto! Agora ele acordou e está em pé.",
	"Maravilha, mas então... você sabe o que fez?"
]

# Textos para quando o usuário escolhe "abrir o olho" (opção 1)
var yellow_path_olho_texts = [
	"Agora que você abriu o olho, só falta levantar.",
	"*Protagonista se levanta*", # Texto de contexto, não será exibido
	"*Protagonista agora em pé com os olhos abertos*", # Texto de contexto, não será exibido
	"Pronto! Agora ele acordou e está em pé.",
	"Maravilha, mas então... você sabe o que fez?"
]

# Variável para controlar qual caminho amarelo será usado
var yellow_path_texts = [] # Será definida dinamicamente

var conclusion_standard_texts = [
	"O que você acabou de ver foi um algoritmo, um passo a passo lógico para concluir um objetivo.",
	"O objetivo dele era acordar e sair da cama, o que significa que você concluiu seu primeiro algoritmo."
]

var conclusion_blue_path_texts = [
	"O que você acabou de ver foi um algoritmo, mesmo que de um jeito um pouco... caótico.",
	"O objetivo dele era acordar e sair da cama, e você conseguiu, mesmo que caindo no chão primeiro!",
	"Isso mostra que algoritmos podem ter diferentes soluções para o mesmo problema."
]

# Variável que será ajustada com base no caminho escolhido
var conclusion_texts = [] # Será definida dinamicamente

func _ready() -> void:
	game_manager = get_node("/root/Game") 
	if not game_manager:
		printerr("Prologue.gd: Game.gd não encontrado em /root/Game!")

	if is_instance_valid(tela_inicial):
		if not tela_inicial.linha_exibida_completamente.is_connected(_avancar_dialogo):
			tela_inicial.linha_exibida_completamente.connect(_avancar_dialogo)
	else:
		printerr("Nó TelaInicial não encontrado em Prologue.gd no _ready!")
	
	# Configurar os diálogos
	if dialogue_box:
		dialogue_box.dialogue_line_finished.connect(_on_dialogue_line_finished)
		dialogue_box.visible = false
	
	if choice_dialogue_box:
		choice_dialogue_box.choice_selected.connect(_on_choice_selected)
		choice_dialogue_box.visible = false
		
	if description_box:
		description_box.dialogue_line_finished.connect(_on_description_line_finished)
		description_box.visible = false
		
	# Criar indicador de clique se ele não existir na cena
	if not click_indicator:
		_create_click_indicator()
		
	# Esconder o indicador no início
	if click_indicator:
		click_indicator.visible = false
		
# Função para criar dinamicamente um indicador de clique se não existir na cena
func _create_click_indicator():
	# Cria uma label simples para indicar que o usuário deve clicar
	var label = Label.new()
	label.name = "ClickIndicator"
	label.text = "Clique para continuar..."
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Posiciona na parte inferior da tela
	label.anchor_bottom = 1.0
	label.anchor_top = 0.9
	label.anchor_left = 0.0
	label.anchor_right = 1.0
	
	# Define algumas propriedades visuais
	label.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	label.add_theme_font_size_override("font_size", 20)
	
	# Adiciona à árvore de nós
	add_child(label)
	click_indicator = label
	
	# Cria uma animação simples de pulso para o indicador
	_create_pulse_animation()
	
# Função para criar uma animação de pulso para o indicador de clique
func _create_pulse_animation():
	if not click_indicator:
		return
	
	# Cria um tween para animar o indicador
	var tween = create_tween()
	tween.set_loops() # Define como loop infinito
	
	# Anima a transparência para criar efeito de pulsar
	tween.tween_property(click_indicator, "modulate:a", 0.4, 1.0)
	tween.tween_property(click_indicator, "modulate:a", 1.0, 1.0)

func _on_scene_activated() -> void:
	print("Prologue: Cena Ativada")
	if not is_instance_valid(tela_inicial):
		printerr("Nó TelaInicial não encontrado em Prologue.gd em _on_scene_activated!")
		return
	
	if not game_manager: 
		game_manager = get_node("/root/Game")
		if not game_manager:
			printerr("Prologue.gd: Game.gd ainda não encontrado! Não é possível verificar o estado da introdução.")
			_iniciar_sequencia_dialogo_completa()
			return

	if game_manager.prologo_introducao_concluida == true:
		print("Prologue: Introdução já concluída. Pulando diálogo da TelaInicial.")
		tela_inicial.visible = false
		_iniciar_sequencia_jogador_dormindo()
	else:
		_iniciar_sequencia_dialogo_completa()

func _iniciar_sequencia_dialogo_completa() -> void:
	if not is_instance_valid(tela_inicial): return

	indice_linha_atual = 0
	tela_inicial.visible = true
	
	await tela_inicial.mostrar_fundo(0.5) 
	_exibir_linha_atual()

func _iniciar_sequencia_jogador_dormindo() -> void:
	if DEBUG_DIALOGUE:
		print("[Sistema] Iniciando sequência de diálogo interativo do prólogo...")
		print("[Sistema] Modo de depuração ATIVADO - logs detalhados serão exibidos")
	else:
		print("Iniciando sequência de diálogo interativo...")
	
	# Esconder a tela inicial e mostrar os diálogos
	if tela_inicial and tela_inicial.visible:
		tela_inicial.visible = false
		
	# Resetar variáveis de controle do diálogo
	dialogue_active = true
	current_state = DialogueState.INTRO
	current_text_index = 0
	current_path = PATH_STANDARD
	
	# Resetar as escolhas para o estado inicial
	reset_choices()
	
	if DEBUG_DIALOGUE:
		print("[Sistema] Estado inicial configurado: ", DialogueState.keys()[current_state])
		print("[Sistema] Opções de escolha resetadas para o estado inicial")
	
	# Resetar visibilidade de todas as caixas de diálogo
	if dialogue_box:
		dialogue_box.visible = false
	if description_box:
		description_box.visible = false
	if choice_dialogue_box:
		choice_dialogue_box.visible = false
	if click_indicator:
		click_indicator.visible = false
	
	# Mostrar o primeiro texto do diálogo interativo
	show_appropriate_text(intro_texts[current_text_index])

# Função removida pois não é mais necessária
# func _on_dialogue_sequence_completed() -> void:
# 	print("Prologue: Sequência de diálogo interativa concluída!")
# 	dialogue_completed = true
# 	_prosseguir_apos_dialogo()

func _on_scene_deactivating() -> void:
	print("Prologue: Cena Desativada")
	if is_instance_valid(tela_inicial):
		tela_inicial.parar_e_limpar_linha_atual()
		if is_instance_valid(tela_inicial.fundo_preto):
			tela_inicial.fundo_preto.modulate.a = 0.0 
			tela_inicial.fundo_preto.visible = false 
		if is_instance_valid(tela_inicial.texto_label):
			tela_inicial.texto_label.modulate.a = 0.0
	
	# Esconder todos os diálogos
	if dialogue_box:
		dialogue_box.hide_box()
		dialogue_box.visible = false
		
	if choice_dialogue_box:
		choice_dialogue_box.hide_box()
		choice_dialogue_box.visible = false
		
	if description_box:
		description_box.hide_box()
		description_box.visible = false

func _exibir_linha_atual() -> void:
	if not is_instance_valid(tela_inicial): return

	if indice_linha_atual < linhas_dialogo.size():
		tela_inicial.exibir_linha_dialogo(linhas_dialogo[indice_linha_atual])
	else:
		_finalizar_dialogo_da_introducao()

func _avancar_dialogo() -> void:
	indice_linha_atual += 1
	_exibir_linha_atual()

func _finalizar_dialogo_da_introducao() -> void:
	print("Prologue: Fim dos diálogos da introdução (TelaInicial).")
	
	if game_manager:
		game_manager.prologo_introducao_concluida = true
		print("Prologue: Flag 'prologo_introducao_concluida' definida como true.")

	if is_instance_valid(tela_inicial):
		await tela_inicial.esconder_fundo(1.0)
	
	_iniciar_sequencia_jogador_dormindo()

func _prosseguir_apos_dialogo() -> void:
	print("Prologue: Diálogo interativo concluído, avançando para gameplay...")
	if game_manager and game_manager.has_method("navigate_to_gameplay"):
		game_manager.navigate_to_gameplay("loading")
	else:
		printerr("Prologue: Não foi possível encontrar Game.gd ou o método navigate_to_gameplay.")

# Função auxiliar para verificar se o texto é uma descrição (textos com asteriscos)
func is_description_text(text: String) -> bool:
	# 1. Caso mais comum: texto começa com asterisco
	if text.begins_with("*"):
		return true
		
	# 2. Texto está completamente entre asteriscos
	if text.begins_with("*") and text.ends_with("*"):
		return true
	
	# 3. Texto começa com comentário de código (usado nas linhas de contexto)
	if text.begins_with("#"):
		return true
		
	# 4. Se o texto contém asterisco em qualquer lugar
	if "*" in text:
		# Verificamos se contém palavras-chave de contexto para determinar se é uma instrução
		var context_keywords = [
			"protagonista", "revela-se", "executa", "cai", "dormindo", 
			"caminhando", "sentado", "levanta", "contexto", "scene"
		]
		for keyword in context_keywords:
			if keyword.to_lower() in text.to_lower():
				return true
	
	return false

# Função para mostrar o texto apropriado (diálogo ou descrição)
func show_appropriate_text(text: String) -> void:
	if is_description_text(text):
		# Este texto contém asteriscos e é uma instrução de contexto
		# Isto não deve ser exibido como diálogo para o jogador
		if DEBUG_DIALOGUE:
			print("[Contexto] Texto ignorado (com asteriscos): ", text)
		
		# Esconde todas as caixas de diálogo para garantir que nada aparece
		dialogue_box.visible = false
		description_box.visible = false
		choice_dialogue_box.visible = false
		if click_indicator:
			click_indicator.visible = false
		
		# Configurar flags para pular a espera de input
		waiting_for_input = false
		text_displayed_completely = true
		
		# Avança automaticamente para o próximo texto (apenas para textos de contexto)
		call_deferred("_process_next_dialogue_state")
	else:
		# Texto normal de diálogo para ser mostrado ao jogador
		if DEBUG_DIALOGUE:
			print("[Diálogo] Mostrando: ", text)
			
		# Resetar flags de controle de input
		waiting_for_input = true
		text_displayed_completely = false
		
		# Escondemos o indicador
		if click_indicator:
			click_indicator.visible = false
			
		dialogue_box.visible = true
		description_box.visible = false
		dialogue_box.show_line(text)

func _on_dialogue_line_finished():
	# Marca que o texto foi exibido completamente e estamos esperando input do usuário
	text_displayed_completely = true
	
	if DEBUG_DIALOGUE:
		print("[Diálogo] Texto completamente exibido. Esperando input? ", waiting_for_input)
	
	# Se for um texto de contexto, avança automaticamente sem esperar input
	if not waiting_for_input:
		_process_next_dialogue_state()
	# Se não, esperamos pelo clique do usuário (que chamará _advance_dialogue)
	else:
		# Mostrar indicador visual de que o usuário precisa clicar para continuar
		if click_indicator:
			click_indicator.visible = true
			
		if DEBUG_DIALOGUE:
			print("[Diálogo] Aguardando clique do usuário para continuar...")

# Função que processa o próximo estado de diálogo
func _process_next_dialogue_state():
	current_text_index += 1
	
	if DEBUG_DIALOGUE:
		print("[Estado] ", DialogueState.keys()[current_state], " | Índice: ", current_text_index)
		print("[Caminho Atual] ", "AZUL" if current_path == PATH_BLUE else "PADRÃO")
	
	match current_state:
		DialogueState.INTRO:
			if current_text_index < intro_texts.size():
				show_appropriate_text(intro_texts[current_text_index])
			else:
				if DEBUG_DIALOGUE:
					print("[Transição] INTRO -> FIRST_CHOICE")
				current_state = DialogueState.FIRST_CHOICE
				show_choice_options(DialogueState.FIRST_CHOICE)
				
		DialogueState.FIRST_CHOICE:
			# Se chegamos aqui, é porque o jogador fez uma escolha incorreta
			# e precisamos mostrar as opções atualizadas
			if DEBUG_DIALOGUE:
				print("[Escolha] Mostrando opções atualizadas da primeira escolha")
			show_choice_options(DialogueState.FIRST_CHOICE)
			
		DialogueState.SECOND_CHOICE:
			# Se chegamos aqui, é porque o jogador fez uma escolha incorreta
			# e precisamos mostrar as opções atualizadas
			if DEBUG_DIALOGUE:
				print("[Escolha] Mostrando opções atualizadas da segunda escolha")
			show_choice_options(DialogueState.SECOND_CHOICE)
		
		DialogueState.BLUE_PATH:
			if current_text_index < blue_path_texts.size():
				show_appropriate_text(blue_path_texts[current_text_index])
			else:
				if DEBUG_DIALOGUE:
					print("[Escolha] Mostrando opções do BLUE_PATH")
				show_choice_options(DialogueState.BLUE_PATH)
		
		DialogueState.BLUE_PATH_CONTINUATION:
			if current_text_index < blue_path_continuation_texts.size():
				show_appropriate_text(blue_path_continuation_texts[current_text_index])
			else:
				if DEBUG_DIALOGUE:
					print("[Transição] BLUE_PATH_CONTINUATION -> CONCLUSION (Caminho Azul)")
				current_state = DialogueState.CONCLUSION
				current_text_index = 0
				
				# Define os textos de conclusão para o caminho azul
				conclusion_texts = conclusion_blue_path_texts.duplicate()
				show_appropriate_text(conclusion_texts[current_text_index])
				
		DialogueState.YELLOW_PATH:
			if current_text_index < yellow_path_texts.size():
				show_appropriate_text(yellow_path_texts[current_text_index])
			else:
				if DEBUG_DIALOGUE:
					print("[Transição] YELLOW_PATH -> CONCLUSION (Caminho Padrão)")
				current_state = DialogueState.CONCLUSION
				current_text_index = 0
				
				# Define os textos de conclusão para o caminho padrão
				conclusion_texts = conclusion_standard_texts.duplicate()
				show_appropriate_text(conclusion_texts[current_text_index])
				
		DialogueState.CONCLUSION:
			if current_text_index < conclusion_texts.size():
				show_appropriate_text(conclusion_texts[current_text_index])
			else:
				if DEBUG_DIALOGUE:
					print("[Fim] Sequência de diálogo concluída")
				finish_interactive_dialogue()

func _on_description_line_finished():
	# Reutiliza a mesma lógica da função de diálogo
	_on_dialogue_line_finished()

func _on_choice_selected(choice_index: int):
	selected_option = choice_index
	choice_dialogue_box.visible = false
	
	match current_state:
		DialogueState.FIRST_CHOICE:
			# Use show_appropriate_text para garantir que textos de contexto sejam tratados corretamente
			show_appropriate_text(after_first_choice_texts[choice_index])
			
			# Se escolheu "acordar", avança, caso contrário, volta para mostrar opções
			if choice_index == 0:  # "a) acordar" - Caminho correto
				if DEBUG_DIALOGUE:
					print("[Escolha] Escolha correta (acordar) na primeira etapa")
					
				current_text_index = 0
				current_state = DialogueState.SECOND_CHOICE
				
				# Resetamos as escolhas da segunda etapa (por segurança)
				second_choices = original_second_choices.duplicate()
				incorrect_second_choices.clear()
			else:
				# Marca esta opção como incorreta usando nossa função auxiliar
				var selected_option_text = first_choices[choice_index]
				first_choices = mark_option_as_incorrect(selected_option_text, original_first_choices, incorrect_first_choices)
				
				if DEBUG_DIALOGUE:
					print("[Escolha] Escolha incorreta, opções restantes: ", first_choices)
				
				# Voltar para o estado de primeira escolha para mostrar as opções atualizadas
				current_text_index = -1  # Para que _process_next_dialogue_state incremente para 0
			
		DialogueState.SECOND_CHOICE:
			# Use show_appropriate_text para verificar se há instruções de contexto
			show_appropriate_text(after_second_choice_texts[choice_index])
			
			if choice_index == 2:  # 'd) sair da cama' - Opção AZUL
				# Caminho azul é sempre válido (escolha especial)
				current_state = DialogueState.BLUE_PATH
				current_text_index = -1  # Para que _process_next_dialogue_state incremente para 0
				current_path = PATH_BLUE
				
				if DEBUG_DIALOGUE:
					print("[Caminho] Definido caminho AZUL")
			else:  # Outras opções - Caminho AMARELO potencial
				# Verifica se a resposta está correta com base no texto de resposta
				# Resposta errada tem "vai" no início (ex: "vai sair deitado?")
				if after_second_choice_texts[choice_index].begins_with("vai"):
					# Esta é uma resposta incorreta
					var selected_option_text = second_choices[choice_index]
					second_choices = mark_option_as_incorrect(selected_option_text, original_second_choices, incorrect_second_choices)
					
					if DEBUG_DIALOGUE:
						print("[Escolha] Resposta incorreta na segunda etapa, mostrando opções atualizadas")
					
					current_text_index = -1  # Volta para mostrar as escolhas atualizadas
				else:
					# Se a resposta for correta ("isso mesmo"), segue para o caminho amarelo
					# Primeiro determina qual conjunto de textos usar com base na escolha
					if choice_index == 0: # "b) levantar"
						yellow_path_texts = yellow_path_levantar_texts.duplicate()
						if DEBUG_DIALOGUE:
							print("[Caminho] AMARELO - via levantar")
					else: # "c) abrir o olho"
						yellow_path_texts = yellow_path_olho_texts.duplicate() 
						if DEBUG_DIALOGUE:
							print("[Caminho] AMARELO - via abrir olho")
					
					# Depois atualiza o estado e caminho
					current_state = DialogueState.YELLOW_PATH
					current_text_index = -1  # Para que _process_next_dialogue_state incremente para 0
					current_path = PATH_STANDARD
				
		DialogueState.BLUE_PATH:
			# Use show_appropriate_text para verificar se há instruções de contexto
			show_appropriate_text(blue_path_responses[choice_index])
			
			# Determina qual conjunto de textos adicionais usar com base na escolha
			if choice_index == 0: # "a) levantar"
				blue_path_continuation_texts = blue_path_levantar_texts.duplicate()
				if DEBUG_DIALOGUE:
					print("[Caminho] AZUL - continua via levantar")
			else: # "b) abrir o olho"
				blue_path_continuation_texts = blue_path_olho_texts.duplicate()
				if DEBUG_DIALOGUE:
					print("[Caminho] AZUL - continua via abrir olho")
			
			# Após resposta, vamos para um estado intermediário antes da conclusão
			current_state = DialogueState.BLUE_PATH_CONTINUATION
			current_text_index = -1  # Para que _process_next_dialogue_state incremente para 0

func show_choice_options(state: DialogueState):
	# Esconder todas as outras caixas de diálogo
	dialogue_box.hide_box()
	description_box.hide_box()
	
	# Mostrar a caixa de escolha
	choice_dialogue_box.visible = true
	
	match state:
		DialogueState.FIRST_CHOICE:
			# Verificar se ainda temos opções disponíveis
			if first_choices.size() <= 1:  # Deixamos pelo menos a opção correta ("acordar")
				# Se não tiver mais opções ou só restar uma, reinicia as opções
				first_choices = original_first_choices.duplicate()
				incorrect_first_choices.clear()
				if DEBUG_DIALOGUE:
					print("[Sistema] Opções da primeira escolha reiniciadas.")
					
			if DEBUG_DIALOGUE:
				print("[Escolhas] Exibindo opções para primeira escolha: ", first_choices)
				
			choice_dialogue_box.show_choices(first_choices, "O que você vai fazer?")
			
		DialogueState.SECOND_CHOICE:
			# Verificar se ainda temos opções disponíveis
			if second_choices.size() == 0:
				# Se não tiver mais opções, reinicia as opções
				second_choices = original_second_choices.duplicate()
				incorrect_second_choices.clear()
				if DEBUG_DIALOGUE:
					print("[Sistema] Todas as opções da segunda escolha foram tentadas. Reiniciando.")
			elif second_choices.size() == 1 && second_choices[0].ends_with("sair da cama"):
				# Se só restar a opção "sair da cama", também reiniciamos
				# para garantir que as outras opções também sejam mostradas
				second_choices = original_second_choices.duplicate()
				incorrect_second_choices.clear()
				if DEBUG_DIALOGUE:
					print("[Sistema] Restando apenas opção azul. Reiniciando opções.")
					
			if DEBUG_DIALOGUE:
				print("[Escolhas] Exibindo opções para segunda escolha: ", second_choices)
				
			choice_dialogue_box.show_choices(second_choices, "Agora que ele está acordado, o que vem depois?")
			
		DialogueState.BLUE_PATH:
			if DEBUG_DIALOGUE:
				print("[Escolhas] Exibindo opções do caminho azul")
				
			choice_dialogue_box.show_choices(blue_path_choices, "O que vem agora?")

func finish_interactive_dialogue():
	# Esconder todas as caixas de diálogo
	dialogue_box.hide_box()
	choice_dialogue_box.hide_box()
	description_box.hide_box()
	if click_indicator:
		click_indicator.visible = false
	
	# Salvar resultados do diálogo antes de prosseguir
	_save_dialogue_choices()
	
	dialogue_active = false
	_prosseguir_apos_dialogo()

# Função para salvar as escolhas importantes do diálogo (para uso futuro se necessário)
func _save_dialogue_choices():
	if game_manager:
		# Podemos salvar informações sobre as escolhas do jogador para uso futuro
		# Se o game_manager tiver este método (mesmo que não tenha agora, pode ser implementado depois)
		if game_manager.has_method("set_player_choice_data"):
			var choice_data = {
				"path": current_path,
				"first_choice": selected_option,
				"completed": true
			}
			
			game_manager.set_player_choice_data("prologue", choice_data)
			
			if DEBUG_DIALOGUE:
				print("[Persistência] Salvando dados de escolha: ", choice_data)

func _input(event):
	# Só processa input quando o diálogo está ativo
	if not dialogue_active:
		return
		
	# Verifica se é um evento de clique, toque ou tecla de espaço/enter
	if ((event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or \
	   (event is InputEventScreenTouch and event.pressed) or \
	   (event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER))):
		
		if DEBUG_DIALOGUE:
			print("[Input] Detectado clique ou tecla")
		
		# Se estivermos esperando por input do usuário para avançar o diálogo
		if waiting_for_input and text_displayed_completely:
			# Avança para o próximo texto
			if DEBUG_DIALOGUE:
				print("[Input] Avançando diálogo por clique do usuário")
				
			waiting_for_input = false
			_advance_dialogue()
			
		# Se o texto ainda está sendo digitado, acelerar a digitação
		elif dialogue_box.visible and dialogue_box.is_typewriting():
			if DEBUG_DIALOGUE:
				print("[Input] Acelerando digitação de diálogo")
				
			dialogue_box.advance_or_skip_typewriter()
			
		elif description_box.visible and description_box.is_typewriting():
			if DEBUG_DIALOGUE:
				print("[Input] Acelerando digitação de descrição")
				
			description_box.skip_typewriter_effect()

# Função para avançar o diálogo após o clique do usuário
func _advance_dialogue():
	if DEBUG_DIALOGUE:
		print("[Input] Usuário avançou o diálogo")
	
	# Esconder o indicador de clique
	if click_indicator:
		click_indicator.visible = false
	
	# Resetamos a flag de espera por input
	waiting_for_input = false
	text_displayed_completely = false
	
	# Processamos o próximo estado de diálogo
	_process_next_dialogue_state()

# Função para marcar uma opção como incorreta e removê-la das escolhas disponíveis
func mark_option_as_incorrect(option_text: String, choices_array: Array, incorrect_array: Array) -> Array:
	if not option_text in incorrect_array:
		incorrect_array.append(option_text)
		
		if DEBUG_DIALOGUE:
			print("[Escolha] Marcada como incorreta e removida: ", option_text)
	
	# Atualiza a lista de escolhas disponíveis removendo as opções incorretas
	var updated_choices = []
	for choice in choices_array:
		# Não inclui opções incorretas, exceto se for a primeira opção da primeira escolha
		# que sempre precisa estar disponível (opção "acordar")
		if not choice in incorrect_array or (choice == "a) acordar" and choices_array == original_first_choices):
			updated_choices.append(choice)
	
	return updated_choices

# Função para resetar as escolhas e limpar o histórico de incorretas
func reset_choices():
	first_choices = original_first_choices.duplicate()
	incorrect_first_choices.clear()
	second_choices = original_second_choices.duplicate()
	incorrect_second_choices.clear()
	
	if DEBUG_DIALOGUE:
		print("[Sistema] Opções de escolha resetadas")
