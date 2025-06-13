extends Node 

# Constantes para modo de depuração
const DEBUG_DIALOGUE = true # Ative para ver logs detalhados do fluxo de diálogo

# Constantes para identificar os caminhos
const PATH_STANDARD = 0 # Caminho padrão (amarelo)
const PATH_BLUE = 1     # Caminho alternativo (azul)

# Variáveis para controle do skip
var space_press_count = 0
var last_space_press_time = 0
const SPACE_PRESS_INTERVAL = 1.0  # Intervalo máximo entre pressionamentos (1 segundo)
const SPACE_PRESS_REQUIRED = 3     # Número de pressionamentos necessários

# Nota: O sistema de portas agora é gerenciado pelo script prologue_doors.gd

@onready var tela_inicial: Control = $TelaInicial
@onready var dialogue_box = $DialogueBoxUI
@onready var choice_dialogue_box = $ChoiceDialogueBox
@onready var description_box = $DescriptionBoxUI
@onready var click_indicator = $ClickIndicator if has_node("ClickIndicator") else null
@onready var player = $Player/Body if has_node("Player/Body") else null

# Variáveis para controlar a espera por clique do usuário
var waiting_for_input = false
var text_displayed_completely = false

# Rastreamento do caminho do usuário
var current_path = PATH_STANDARD

var linhas_dialogo: Array[String] = [
	"Olha só, um rosto novo, muito prazer",
	"Quem eu sou não é importante, mas eu ainda vou falar muito com você. \nE você vai falar muito com ele",
	"Quer conhecer ele?"
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
	CONCLUSION,
	FINAL_DIALOGUE  # Novo estado para diálogo final após conclusão
}

# Estado atual do diálogo
var current_state = DialogueState.INTRO
var current_text_index = 0
var selected_option = -1
var dialogue_active = false

# Textos do roteiro
var intro_texts = [
	"Aí está nosso carinha, um faz-tudo que, bom... faz de tudo",
	"ele está dormindo em sua confortável cama.",
	"...",
	"ou deveria ser uma cama... bom, o importante é o conforto, né?",
	"Enfim, Ele está dormindo, o que você vai fazer?"
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
	2: "Algumas pessoas dormem de olho aberto, não acho que seja o caso dele", # abrir o olho
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
	0: "boa, tu levantou, mas... num era pra você já ter aberto o olho?", # levantar
	1: "boa, tu abriu o olho, então agora só falta?", # abrir o olho
	2: "O_O" # sair da cama
}

var blue_path_texts = [
	"*Protagonista cai da cama*", # Texto de contexto, não será exibido
	"Muito bem, você esbagaçou ele no chão, mas ele ainda vai viver, com dor nas costas, mas vai viver. Mas iai, o que vem a seguir?"
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
	"É, tu levantou, de olho fechado... mas levantou.",
	"Vamos fingir que seus olhos estão abertos.",
	"Ótimo! A sequência foi concluída, mesmo que de um jeito... diferente."
]

var blue_path_olho_texts = [
	
	"Interessante você preferir abrir o olho do que levantar.",
	"mas eu não tô aqui pra julgar, muito.",
	"Ótimo! O algoritmo foi concluído, mesmo que de um jeito... diferente."
]

# Variável para controlar qual caminho de resposta azul será usado
var blue_path_continuation_texts = [] # Será definida dinamicamente

# Textos para quando o usuário escolhe "levantar" (opção 0)
var yellow_path_levantar_texts = [
	"pronto, agora sim está tudo certo.",
	"Dito isso. você sabe o que acabou de fazer?"
]

# Textos para quando o usuário escolhe "abrir o olho" (opção 1)
var yellow_path_olho_texts = [
	"pronto, agora sim está tudo certo.",
	"Dito isso. você sabe o que acabou de fazer?"
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
	"Isso mostra que algoritmos podem ter diferentes soluções para o mesmo problema.",
	"Então meus parabéns por concluir seu primeiro algoritmo"
]

# Variável que será ajustada com base no caminho escolhido
var conclusion_texts = [] # Será definida dinamicamente

# Textos para o diálogo final após a conclusão principal
var final_dialogue_texts = [
	"Agora que você tá de pé, e eu não tenho mais animações dele, que tal sairmos desse castelo luxuoso e irmos para fora?",
	"ele precisa trabalhar apesar de tudo"
]

func _ready() -> void:
	game_manager = get_node("/root/Game") 
	if not game_manager:
		printerr("Prologue.gd: Game.gd não encontrado em /root/Game!")

	# Configurar colisão para o sofá
	setup_couch_collision()

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
		
	# Adiciona o script de gerenciamento de portas interativas
	var door_manager = Node.new()
	door_manager.name = "DoorManager"
	door_manager.set_script(load("res://scenes/prologue/Início/prologue_doors.gd"))
	add_child(door_manager)
	
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
	
	# Garantir que o indicador está visível e com a opacidade correta
	click_indicator.modulate.a = 1.0
	
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
	
	# Verificar e obter referência para o game_manager
	if not game_manager: 
		game_manager = get_node("/root/Game")
		if not game_manager:
			printerr("Prologue.gd: Game.gd ainda não encontrado! Não é possível verificar o estado da introdução.")
			print("DEBUG: Iniciando sequência de diálogo completa sem verificar flag.")
			_iniciar_sequencia_dialogo_completa()
			return
	
	# Verificar o estado da flag do prólogo
	print("Prologue: Verificando flag 'prologo_introducao_concluida' = ", game_manager.prologo_introducao_concluida)
	
	if game_manager.prologo_introducao_concluida == true:
		print("Prologue: Introdução já concluída. Pulando diálogo e indo direto para gameplay.")
		tela_inicial.visible = false
		_iniciar_sequencia_jogador_dormindo()
	else:
		print("Prologue: Primeira vez jogando. Iniciando sequência de diálogo completa.")
		_iniciar_sequencia_dialogo_completa()

func _iniciar_sequencia_dialogo_completa() -> void:
	if not is_instance_valid(tela_inicial): return

	indice_linha_atual = 0
	tela_inicial.visible = true
	
	await tela_inicial.mostrar_fundo(0.5) 
	_exibir_linha_atual()

func _iniciar_sequencia_jogador_dormindo() -> void:
	# Verificar o estado da flag do prólogo
	print("Prologue: Iniciando sequência jogador dormindo. Verificando flag: ", 
		game_manager.prologo_introducao_concluida if game_manager else "sem game_manager")
	
	# Verificar se o prólogo já foi completado anteriormente e se devemos pular para o gameplay
	if game_manager and game_manager.prologo_introducao_concluida == true:
		# O jogador já completou o prólogo antes, pular automaticamente para o gameplay
		print("Prologue: Prólogo já foi concluído. Pulando diálogo e indo direto para o gameplay.")
		dialogue_active = false
		_prosseguir_apos_dialogo()
		return
	
	# Se chegamos aqui, o jogador está vendo o prólogo pela primeira vez
	print("Prologue: PRIMEIRA VEZ - Iniciando sequência de diálogo interativo do prólogo.")
	print("Prologue: Verificação de intro_texts (tamanho): ", intro_texts.size())
	print("Prologue: Verificação de dialogue_box disponível: ", is_instance_valid(dialogue_box))
	
	# Debug adicional para garantir que dialogue_box está presente
	if not dialogue_box:
		dialogue_box = $DialogueBoxUI
		print("Prologue: Tentando recuperar dialogue_box = ", is_instance_valid(dialogue_box))
	
	# Vamos garantir que o diálogo seja iniciado corretamente
	if DEBUG_DIALOGUE:
		print("[Sistema] Configurando sequência de diálogo interativo do prólogo...")
	
	
	if DEBUG_DIALOGUE:
		print("[Sistema] Iniciando sequência de diálogo interativo do prólogo...")
		print("[Sistema] Modo de depuração ATIVADO - logs detalhados serão exibidos")
	else:
		print("Iniciando sequência de diálogo interativo...")
	
	# Esconder joystick virtual (se existir)
	if player and player.has_method("hide_joystick"):
		player.hide_joystick()
		
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
	
	# Verificação adicional para textos que começam com frases de contexto comuns
	var context_phrases = ["texto de contexto", "não será exibido"]
	for phrase in context_phrases:
		if text.to_lower().contains(phrase):
			return true
	
	return false

# Função para mostrar o texto apropriado (diálogo ou descrição)
func show_appropriate_text(text: String) -> void:
	print("Prologue: show_appropriate_text chamado com texto: ", text)
	
	# Verificação para texto vazio ou nulo
	if text.strip_edges() == "":
		print("Prologue: Texto vazio detectado, ignorando")
		if DEBUG_DIALOGUE:
			print("[Contexto] Texto vazio ignorado")
		
		# Avança automaticamente para o próximo texto (não há nada para mostrar)
		call_deferred("_process_next_dialogue_state")
		return
		
	if is_description_text(text):
		# Este texto contém asteriscos e é uma instrução de contexto
		# Isto não deve ser exibido como diálogo para o jogador
		print("Prologue: Texto de descrição detectado (não será mostrado ao jogador)")
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
		print("Prologue: Mostrando texto de diálogo ao jogador: ", text)
		print("Prologue: dialogue_box válido? ", is_instance_valid(dialogue_box))
		
		if DEBUG_DIALOGUE:
			print("[Diálogo] Mostrando: ", text)
			
		# Resetar flags de controle de input
		waiting_for_input = true
		text_displayed_completely = false
		
		# Escondemos o indicador
		if click_indicator:
			click_indicator.visible = false
		
		# Garantimos que outras caixas estão escondidas
		description_box.visible = false
		choice_dialogue_box.visible = false
		
		# Verificar novamente se a dialogue_box existe
		if not is_instance_valid(dialogue_box):
			dialogue_box = $DialogueBoxUI
			print("Prologue: Tentativa de recuperar dialogue_box: ", is_instance_valid(dialogue_box))
			
		# Mostramos a caixa de diálogo
		if is_instance_valid(dialogue_box):
			dialogue_box.visible = true
			dialogue_box.show_line(text)
			print("Prologue: Texto enviado para dialogue_box")
		else:
			printerr("Prologue: ERRO - dialogue_box não encontrado!")

func _on_dialogue_line_finished():
	# Marca que o texto foi exibido completamente e estamos esperando input do usuário
	text_displayed_completely = true
	
	# Aplicar o cooldown ao finalizar um diálogo para evitar avanços rápidos
	last_input_time = Time.get_ticks_msec() / 1000.0
	
	if DEBUG_DIALOGUE:
		print("[Diálogo] Texto completamente exibido. Esperando input? ", waiting_for_input)
	
	# Se for um texto de contexto, avança automaticamente sem esperar input
	if not waiting_for_input:
		_process_next_dialogue_state()
	# Caso especial: quando estamos no estado SECOND_CHOICE e temos apenas uma opção restante,
	# isso significa que precisamos mostrar a segunda parte do diálogo após "levantar" ou "abrir o olho"
	elif current_state == DialogueState.SECOND_CHOICE and second_choices.size() == 1:
		if DEBUG_DIALOGUE:
			print("[Diálogo] Caminho amarelo - mostrando próxima escolha necessária: ", second_choices)
		
		# Mostrar o indicador de clique primeiro
		if click_indicator:
			click_indicator.visible = true
			
		if DEBUG_DIALOGUE:
			print("[Diálogo] Aguardando clique do usuário para mostrar próxima escolha...")
	# Caso especial: após primeira escolha correta (acordar), mostrar texto e depois as opções da segunda etapa
	elif current_state == DialogueState.SECOND_CHOICE and second_choices.size() > 1:
		# Mostrar o indicador de clique para o usuário avançar manualmente
		if click_indicator:
			click_indicator.visible = true
		
		if DEBUG_DIALOGUE:
			print("[Diálogo] Primeira escolha concluída, aguardando clique para segunda etapa.")

# Função que processa o próximo estado de diálogo
func _process_next_dialogue_state():
	current_text_index += 1
	
	# Aplicar cooldown para evitar progressão acelerada
	last_input_time = Time.get_ticks_msec() / 1000.0
	
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
			# Não reiniciamos automaticamente caso selecionada uma opção incorreta
			# Em vez disso, mostramos as opções atualizadas
			show_choice_options(DialogueState.FIRST_CHOICE)
		
		DialogueState.FINAL_DIALOGUE:
			# Processo para o diálogo final após a conclusão principal
			if current_text_index < final_dialogue_texts.size():
				show_appropriate_text(final_dialogue_texts[current_text_index])
			else:
				if DEBUG_DIALOGUE:
					print("[Fim] Diálogo final concluído, encerrando fluxo de diálogos")
				_complete_all_dialogues()
			
		DialogueState.SECOND_CHOICE:
			# Não reinistalizamos automaticamente caso selecionada uma opção incorreta
			show_choice_options(DialogueState.SECOND_CHOICE)
		
		DialogueState.BLUE_PATH:
			if current_text_index < blue_path_texts.size():
				show_appropriate_text(blue_path_texts[current_text_index])
			else:
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
			# Verificar se a lista de textos está vazia ou nula
			if yellow_path_texts.size() == 0:
				if DEBUG_DIALOGUE:
					print("[ERRO] yellow_path_texts está vazio, preenchendo com valores padrão")
				
				# Definir valores padrão para o caminho amarelo
				yellow_path_texts = [
					"*Protagonista completa as ações necessárias*",
					"pronto, agora sim está tudo certo.",
					"Maravilha, mas então... você sabe o que fez?"
				]
				
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
			# Verificar se os textos de conclusão estão vazios
			if conclusion_texts.size() == 0:
				if DEBUG_DIALOGUE:
					print("[ERRO] conclusion_texts está vazio, usando textos padrão.")
				conclusion_texts = conclusion_standard_texts.duplicate()
				if conclusion_texts.size() == 0:
					# Fallback caso conclusion_standard_texts também esteja vazio
					conclusion_texts = [
						"O que você acabou de ver foi um algoritmo, um passo a passo lógico para concluir um objetivo.",
						"O objetivo dele era acordar e sair da cama, o que significa que você concluiu seu primeiro algoritmo."
					]
					
			if current_text_index < conclusion_texts.size():
				show_appropriate_text(conclusion_texts[current_text_index])
			else:
				if DEBUG_DIALOGUE:
					print("[Fim] Sequência de diálogo concluída")
				finish_interactive_dialogue()

func _on_description_line_finished():
	# Aplica o cooldown explicitamente antes de chamar a outra função
	last_input_time = Time.get_ticks_msec() / 1000.0
	
	# Reutiliza a mesma lógica da função de diálogo
	_on_dialogue_line_finished()

# Função auxiliar para obter o índice original de uma opção com base no seu texto
func get_original_index_from_text(option_text: String, choices_array: Array) -> int:
	for i in range(choices_array.size()):
		if choices_array[i] == option_text:
			return i
	return -1  # Não encontrado

func _on_choice_selected(choice_index: int):
	# Aplica o cooldown imediatamente ao selecionar uma opção
	# para evitar avanços rápidos após fazer uma escolha
	last_input_time = Time.get_ticks_msec() / 1000.0
	
	selected_option = choice_index
	choice_dialogue_box.visible = false
	
	# Pega o texto da opção selecionada para identificação posterior
	var selected_option_text = choice_dialogue_box.get_option_text(choice_index)
	
	match current_state:
		DialogueState.FIRST_CHOICE:
			# Obtém o texto da opção selecionada
			var option_text = selected_option_text
			
			# Encontra o índice original baseado no texto da opção
			var original_index = get_original_index_from_text(option_text, original_first_choices)
			
			if DEBUG_DIALOGUE:
				print("[Escolha] Primeira escolha selecionada: ", option_text, " (índice original: ", original_index, ")")
			
			# Use show_appropriate_text para garantir que textos de contexto sejam tratados corretamente
			if original_index >= 0:
				show_appropriate_text(after_first_choice_texts[original_index])
			else:
				# Fallback se não encontrarmos o índice original
				show_appropriate_text("Hmm, isso não parece certo.")
				return				# Se escolheu "acordar", avança, caso contrário, volta para mostrar opções
			if option_text == "a) acordar":  # "a) acordar" - Caminho correto - verificando pelo texto
				if DEBUG_DIALOGUE:
					print("[Escolha] Escolha correta (acordar) na primeira etapa")
					
				current_text_index = 0  # Reinicia o contador para o próximo estado
				current_state = DialogueState.SECOND_CHOICE
				
				# Garantir que second_choices contenha as opções corretas
				second_choices = original_second_choices.duplicate()
				
				# Resetar as opções incorretas da segunda escolha para começar limpo
				incorrect_second_choices.clear()
				
				if DEBUG_DIALOGUE:
					print("[Sistema] Opções da segunda escolha resetadas: ", second_choices)
				
				# Não avançar automaticamente para o próximo diálogo
				# Em vez disso, esperar até o diálogo atual terminar
				# _process_next_dialogue_state será chamado quando o texto for exibido completamente
			else:
				# Salva a opção que o jogador tentou
				if not option_text in incorrect_first_choices:
					incorrect_first_choices.append(option_text)
					print("[Debug] Adicionada opção incorreta na primeira escolha: ", option_text)
				
				# Atualizar first_choices para refletir as opções restantes
				first_choices = mark_option_as_incorrect(option_text, original_first_choices, incorrect_first_choices)
				
				if DEBUG_DIALOGUE:
					print("[Escolha] Escolha incorreta, opções restantes: ", first_choices)
				
				# Não continuamos o diálogo automaticamente
				# Em vez disso, o texto de resposta terminará e _on_dialogue_line_finished 
				# irá configurar waiting_for_input = true
			
		DialogueState.SECOND_CHOICE:
			# Obtém o texto da opção selecionada
			var option_text = selected_option_text
			
			# Encontra o índice original baseado no texto da opção
			var original_index = get_original_index_from_text(option_text, original_second_choices)
			
			if DEBUG_DIALOGUE:
				print("[Escolha] Segunda escolha selecionada: ", option_text, " (índice original: ", original_index, ")")
			
			# Verificar se esta é a segunda escolha do algoritmo completo
			# Se second_choices tiver tamanho 1, significa que é a segunda etapa do algoritmo
			if second_choices.size() == 1 and second_choices.has(option_text):
				if DEBUG_DIALOGUE:
					print("[Escolha] Escolha final do algoritmo selecionada: ", option_text)
				
				# Definir qual caminho de texto usar com base na escolha
				if option_text == "b) levantar":
					yellow_path_texts = yellow_path_olho_texts.duplicate()
					if DEBUG_DIALOGUE:
						print("[Caminho] AMARELO - Escolha final 'levantar', usando textos yellow_path_olho_texts")
				else: # "c) abrir o olho"
					yellow_path_texts = yellow_path_levantar_texts.duplicate()
					if DEBUG_DIALOGUE:
						print("[Caminho] AMARELO - Escolha final 'abrir o olho', usando textos yellow_path_levantar_texts")
				
				# Verificar se os textos do caminho amarelo foram configurados corretamente
				if yellow_path_texts.size() == 0:
					printerr("[ERRO] Caminho amarelo não tem textos configurados!")
					if option_text == "b) levantar":
						yellow_path_texts = ["*Protagonista se levanta*", "pronto, agora sim está tudo certo.", "Maravilha, mas então... você sabe o que fez?"]
					else:
						yellow_path_texts = ["*Protagonista abre os olhos*", "pronto, agora sim está tudo certo.", "Maravilha, mas então... você sabe o que fez?"]
				
				# Ir diretamente para o caminho amarelo (conclusão do algoritmo)
				current_state = DialogueState.YELLOW_PATH
				current_text_index = 0
				current_path = PATH_STANDARD
				
				# Esconder a caixa de opções
				choice_dialogue_box.visible = false
				
				# Mostrar o primeiro texto do caminho amarelo
				show_appropriate_text(yellow_path_texts[current_text_index])
				return
			
			# Use show_appropriate_text para verificar se há instruções de contexto
			if original_index >= 0:
				show_appropriate_text(after_second_choice_texts[original_index])
			else:
				# Fallback se não encontrarmos o índice original
				show_appropriate_text("Hmm, isso não parece certo.")
				return
			
			if option_text == "d) sair da cama":  # Opção AZUL - verifica pelo texto e não pelo índice
				# Caminho azul é sempre válido (escolha especial)
				current_state = DialogueState.BLUE_PATH
				current_text_index = 0  # Define explicitamente para 0
				current_path = PATH_BLUE
				
				if DEBUG_DIALOGUE:
					print("[Caminho] Definido caminho AZUL")
					
				# Não avançamos automaticamente, esperamos o texto terminar
			else:  # Outras opções - Caminho AMARELO potencial
				# Verifica se a resposta está correta com base no texto de resposta
				var response_text = after_second_choice_texts[original_index]
				if response_text.begins_with("vai"):
					# Esta é uma resposta incorreta
					
					# Adiciona explicitamente a opção ao array de opções incorretas
					if not option_text in incorrect_second_choices:
						incorrect_second_choices.append(option_text)
						print("[Debug] Adicionada opção incorreta: ", option_text)
					
					# Depois atualiza as opções disponíveis
					second_choices = mark_option_as_incorrect(option_text, original_second_choices, incorrect_second_choices)
					
					if DEBUG_DIALOGUE:
						print("[Escolha] Resposta incorreta na segunda etapa, mostrando opções atualizadas")
						print("[Escolha] Opções incorretas da segunda escolha: ", incorrect_second_choices)
					
					# Não fazemos nada aqui, esperamos o texto ser exibido completamente
				else:
					# Se a resposta for correta (começa com "boa"), preparamos a próxima etapa
					if option_text == "b) levantar":  # "b) levantar" - verificando pelo texto
						# Após levantar, só resta "abrir o olho"
						var filtered_choices = ["c) abrir o olho"]
						yellow_path_texts = yellow_path_levantar_texts.duplicate()
						
						if DEBUG_DIALOGUE:
							print("[Caminho] AMARELO - via levantar, próxima opção: abrir o olho")
						
						# Mostrar o texto de resposta primeiro
						dialogue_box.visible = true
						choice_dialogue_box.visible = false
						dialogue_box.show_line(response_text)
						
						# Armazenar a próxima escolha para quando o diálogo acabar
						# Indicamos que só resta a opção de "abrir o olho"
						second_choices = filtered_choices
						
						# Não transicionamos para YELLOW_PATH ainda, apenas quando selecionada a 
						# segunda opção necessária (abrir o olho)
						waiting_for_input = true
						text_displayed_completely = true
						
						if DEBUG_DIALOGUE:
							print("[Escolha] Aguardando clique para mostrar escolha restante: c) abrir o olho")
						
					else:  # "c) abrir o olho"
						# Após abrir o olho, só resta "levantar"
						var filtered_choices = ["b) levantar"]
						yellow_path_texts = yellow_path_olho_texts.duplicate() 
						
						if DEBUG_DIALOGUE:
							print("[Caminho] AMARELO - via abrir olho, próxima opção: levantar")
						
						# Mostrar o texto de resposta primeiro
						dialogue_box.visible = true
						choice_dialogue_box.visible = false
						dialogue_box.show_line(response_text)
						
						# Armazenar a próxima escolha para quando o diálogo acabar
						# Indicamos que só resta a opção de "levantar"
						second_choices = filtered_choices
						
						# Não transicionamos para YELLOW_PATH ainda, apenas quando selecionada a 
						# segunda opção necessária (levantar)
						waiting_for_input = true
						text_displayed_completely = true
						
						if DEBUG_DIALOGUE:
							print("[Escolha] Aguardando clique para mostrar escolha restante: b) levantar")
				
		DialogueState.BLUE_PATH:
			# Obtém o texto da opção selecionada
			var option_text = choice_dialogue_box.get_option_text(choice_index)
			
			if DEBUG_DIALOGUE:
				print("[Escolha] Caminho Azul - opção selecionada: ", option_text)
			
			# Verifique se o índice é válido para blue_path_responses
			if choice_index < 0 || choice_index >= blue_path_responses.size():
				# Fallback para casos onde o índice está fora dos limites
				if option_text == "a) levantar":
					show_appropriate_text("Maravilha, você levantou, mas por que até agora você não abriu o olho?")
				else:
					show_appropriate_text("De que adianta abrir o olho se você ainda tá no chão?")
			else:
				# Use show_appropriate_text para verificar se há instruções de contexto
				show_appropriate_text(blue_path_responses[choice_index])
			
			# Determina qual conjunto de textos adicionais usar com base na escolha
			if option_text == "a) levantar":  # Verificando pelo texto
				blue_path_continuation_texts = blue_path_levantar_texts.duplicate()
				if DEBUG_DIALOGUE:
					print("[Caminho] AZUL - continua via levantar")
			else:  # "b) abrir o olho"
				blue_path_continuation_texts = blue_path_olho_texts.duplicate()
				if DEBUG_DIALOGUE:
					print("[Caminho] AZUL - continua via abrir olho")
			
			# Verificar se os textos da continuação do caminho azul não estão vazios
			if blue_path_continuation_texts.size() == 0:
				if DEBUG_DIALOGUE:
					print("[ERRO] blue_path_continuation_texts está vazio, adicionando textos de fallback.")
				
				# Adicionar textos fallback
				blue_path_continuation_texts = [
					"*Protagonista completa as ações*",
					"Agora você precisa completar o algoritmo.",
					"*Protagonista completa o algoritmo*",
					"Ótimo! O algoritmo foi concluído, mesmo que de um jeito... diferente."
				]
			
			# Após resposta, vamos para um estado intermediário antes da conclusão
			current_state = DialogueState.BLUE_PATH_CONTINUATION
			current_text_index = 0  # Define explicitamente para 0
			
			# Esconder a caixa de escolhas após a seleção
			choice_dialogue_box.visible = false
			
			# Não avançamos automaticamente, esperamos o texto terminar

func show_choice_options(state: DialogueState):
	# Esconder todas as outras caixas de diálogo
	dialogue_box.hide_box()
	description_box.hide_box()
	
	# Aplicar o cooldown para evitar inputs rápidos após mostrar as opções
	last_input_time = Time.get_ticks_msec() / 1000.0
	
	# Limpar qualquer caixa de escolha anterior
	choice_dialogue_box.visible = false
	
	# Mostrar a caixa de escolha
	choice_dialogue_box.visible = true
	
	match state:
		DialogueState.FIRST_CHOICE:
			# Verificamos se só resta a opção correta (acordar)
			# Nesse caso, não reiniciamos as opções incorretas
			if first_choices.size() <= 0:  # Se não tivermos nenhuma opção (caso extremo)
				first_choices = ["a) acordar"] # Apenas disponibilizamos a opção correta
				if DEBUG_DIALOGUE:
					print("[Sistema] Disponibilizando apenas opção correta da primeira escolha.")
					
			# Filtramos as opções incorretas antes de mostrar
			var filtered_choices = []
			for choice in original_first_choices:
				if not choice in incorrect_first_choices or choice == "a) acordar":
					filtered_choices.append(choice)
			
			# Garantir que temos pelo menos uma opção (a correta) para mostrar
			if filtered_choices.size() == 0:
				filtered_choices = ["a) acordar"]
				if DEBUG_DIALOGUE:
					print("[Sistema] Forçando exibição da opção 'acordar' como fallback.")
					
			if DEBUG_DIALOGUE:
				print("[Escolhas] Exibindo opções filtradas para primeira escolha: ", filtered_choices)
				
			choice_dialogue_box.show_choices(filtered_choices, "O que você vai fazer?")
			
		DialogueState.SECOND_CHOICE:
			# Caso especial: se já estamos na segunda etapa do algoritmo (apenas uma opção disponível)
			if second_choices.size() == 1:
				if DEBUG_DIALOGUE:
					print("[Sistema] Mostrando apenas a opção restante para completar o algoritmo: ", second_choices)
				
				# Usar um título específico baseado na opção restante
				var prompt_title = ""
				if second_choices[0] == "b) levantar":
					prompt_title = "O que falta fazer para completar o algoritmo?"
				else: # "c) abrir o olho"
					prompt_title = "O que falta fazer para completar o algoritmo?"
					
				choice_dialogue_box.show_choices(second_choices, prompt_title)
				return
				
			# Verificar se ainda temos opções disponíveis
			if second_choices.size() == 0:
				# Se não tiver mais opções, mostramos pelo menos as opções corretas 
				# (levantar, abrir o olho e sair da cama)
				second_choices = ["b) levantar", "c) abrir o olho", "d) sair da cama"]
				if DEBUG_DIALOGUE:
					print("[Sistema] Disponibilizando apenas opções corretas da segunda escolha.")
			
			# Filtramos as opções incorretas antes de mostrar as escolhas disponíveis
			var filtered_second_choices = []
			for choice in original_second_choices:
				if not choice in incorrect_second_choices:
					filtered_second_choices.append(choice)
			
			if DEBUG_DIALOGUE:
				print("[Sistema] Segunda escolha - opções incorretas: ", incorrect_second_choices)
				print("[Sistema] Segunda escolha - opções filtradas disponíveis: ", filtered_second_choices)
				
			# Garantir que temos pelo menos uma opção para mostrar
			if filtered_second_choices.size() == 0:
				filtered_second_choices = ["b) levantar", "c) abrir o olho", "d) sair da cama"]
				if DEBUG_DIALOGUE:
					print("[Sistema] Recuperando todas as opções da segunda escolha.")
			
			choice_dialogue_box.show_choices(filtered_second_choices, "Agora que ele está acordado, o que vem depois?")
			
		DialogueState.BLUE_PATH:
			if DEBUG_DIALOGUE:
				print("[Escolhas] Exibindo opções do caminho azul")
				
			choice_dialogue_box.show_choices(blue_path_choices, "O que vem agora?")

func finish_interactive_dialogue():
	# Em vez de finalizar, inicia o diálogo final
	current_state = DialogueState.FINAL_DIALOGUE
	current_text_index = 0
	
	# Verifica se temos textos para mostrar
	if final_dialogue_texts.size() > 0:
		if DEBUG_DIALOGUE:
			print("[Transição] CONCLUSION -> FINAL_DIALOGUE")
		
		# Mostrar o primeiro texto do diálogo final
		show_appropriate_text(final_dialogue_texts[current_text_index])
	else:
		# Se não houver textos finais, continuar com o comportamento original
		_complete_all_dialogues()
		
func _complete_all_dialogues():
	# Esconder todas as caixas de diálogo
	dialogue_box.hide_box()
	choice_dialogue_box.hide_box()
	description_box.hide_box()
	if click_indicator:
		click_indicator.visible = false
	
	# Salvar resultados do diálogo antes de prosseguir
	_save_dialogue_choices()
	
	# Mostrar joystick novamente para a jogabilidade
	if player and player.has_method("show_joystick"):
		player.show_joystick()
	
	dialogue_active = false
	_prosseguir_apos_dialogo()

# Função para salvar as escolhas importantes do diálogo e marcar o prólogo como concluído
func _save_dialogue_choices():
	if game_manager:
		# Define a flag que indica que o prólogo já foi concluído
		# Isso permitirá pular o diálogo quando o jogador iniciar um novo jogo
		game_manager.prologo_introducao_concluida = true
		if DEBUG_DIALOGUE:
			print("[Persistência] Flag 'prologo_introducao_concluida' definida como true.")
		
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

var last_input_time = 0.0
var input_cooldown = 0.3 # Tempo mínimo entre inputs (em segundos)

func _input(event):
	# Detecta pressionamento de tecla para verificar o comando de skip
	# Verifica se o diálogo inicial está visível
	if is_instance_valid(tela_inicial) and tela_inicial.visible:
		if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
			var current_time = Time.get_ticks_msec() / 1000.0
			
			# Se passou mais tempo que o intervalo, reseta a contagem
			if current_time - last_space_press_time > SPACE_PRESS_INTERVAL:
				space_press_count = 0
			
			# Incrementa a contagem de pressionamentos
			space_press_count += 1
			last_space_press_time = current_time
			
			# Se pressionou o espaço 3 vezes em menos de 1 segundo
			if space_press_count >= SPACE_PRESS_REQUIRED:
				space_press_count = 0
				print("Debug: Sequência de skip detectada! Pulando diálogo inicial...")
				_skip_dialogo_inicial()
				
	# Só processa input quando o diálogo está ativo
	if not dialogue_active:
		return
	
	# Proteção contra cliques múltiplos rápidos
	var current_time = Time.get_ticks_msec() / 1000.0
	var time_since_last_input = current_time - last_input_time
	
	if time_since_last_input < input_cooldown:
		if DEBUG_DIALOGUE:
			print("[Input] Ignorando entrada rápida demais (cooldown: ", time_since_last_input, ")")
		return
		
	# Verifica se é um evento de clique, toque ou tecla de espaço/enter
	if ((event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or \
	   (event is InputEventScreenTouch and event.pressed) or \
	   (event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER))):
		
		# Atualiza o tempo do último input
		last_input_time = current_time
		
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
	
	# Aplicar o cooldown para evitar avanço rápido
	last_input_time = Time.get_ticks_msec() / 1000.0
	
	# Esconder o indicador de clique
	if click_indicator:
		click_indicator.visible = false
	
	# Caso especial: se estamos no estado SECOND_CHOICE e temos apenas uma opção restante,
	# mostrar a próxima escolha necessária em vez de avançar o estado
	if current_state == DialogueState.SECOND_CHOICE and second_choices.size() == 1:
		if DEBUG_DIALOGUE:
			print("[Diálogo] Mostrando próxima escolha necessária para completar o algoritmo: ", second_choices)
		
		# Garantimos que a próxima opção seja exibida corretamente
		dialogue_box.visible = false
		show_choice_options(DialogueState.SECOND_CHOICE)
		return
	
	# Resetamos a flag de espera por input
	waiting_for_input = false
	text_displayed_completely = false
	
	# Processamos o próximo estado de diálogo
	_process_next_dialogue_state()

# Função para pular o diálogo inicial completamente
func _skip_dialogo_inicial() -> void:
	# Se a tela inicial não existe ou já está escondida, não faz nada
	if not is_instance_valid(tela_inicial) or not tela_inicial.visible:
		return
		
	# Interrompe qualquer animação de texto em andamento
	tela_inicial.parar_e_limpar_linha_atual()
	
	# Não define a flag prologo_introducao_concluida aqui, pois isso poderia fazer o 
	# próximo _iniciar_sequencia_jogador_dormindo() pular direto para o gameplay
	
	# Esconde a tela inicial imediatamente sem fade
	tela_inicial.visible = false
	
	# Inicia a sequência do jogador dormindo, mas sem pular o diálogo interativo
	print("Prologue: Diálogo inicial da tela inicial pulado via comando de skip.")
	# Não definimos prologo_introducao_concluida = true aqui para garantir que o jogador veja o diálogo pelo menos uma vez
	_iniciar_sequencia_jogador_dormindo()

# Função para marcar uma opção como incorreta e removê-la das escolhas disponíveis
func mark_option_as_incorrect(option_text: String, choices_array: Array, incorrect_array: Array) -> Array:
	if DEBUG_DIALOGUE:
		print("[Escolha] Marcada como incorreta e removida: ", option_text)
		print("[Escolha] Total de opções incorretas antes: ", incorrect_array)
		
	# Garante que a opção seja adicionada ao array de incorretas se ainda não estiver lá
	if not option_text in incorrect_array:
		incorrect_array.append(option_text)
		print("[Debug] Adicionada à lista de incorretas: ", option_text)
	
	if DEBUG_DIALOGUE:
		print("[Escolha] Total de opções incorretas depois: ", incorrect_array)
	
	# Atualiza a lista de escolhas disponíveis removendo as opções incorretas
	var updated_choices = []
	for choice in choices_array:
		# Não inclui opções incorretas, exceto se for a primeira opção da primeira escolha
		# que sempre precisa estar disponível (opção "acordar")
		if not choice in incorrect_array or (choice == "a) acordar" and choices_array == original_first_choices):
			updated_choices.append(choice)
	
	# Verificar se acabamos com uma lista vazia (todas as opções foram marcadas como incorretas)
	# Se sim, devemos mostrar pelo menos uma opção para o jogador não ficar travado
	if updated_choices.size() == 0:
		if choices_array == original_first_choices:
			updated_choices.append("a) acordar")  # Garantir que a opção correta sempre esteja disponível
		elif choices_array == original_second_choices:
			# Na segunda escolha, garantir que pelo menos as opções principais estejam disponíveis
			updated_choices = ["b) levantar", "c) abrir o olho"]
	
	if DEBUG_DIALOGUE:
		print("[Escolha] Escolhas atualizadas após a remoção: ", updated_choices)
	
	return updated_choices

# Função para resetar as escolhas e limpar o histórico de incorretas
func reset_choices():
	first_choices = original_first_choices.duplicate()
	incorrect_first_choices.clear()
	second_choices = original_second_choices.duplicate()
	incorrect_second_choices.clear()
	
	if DEBUG_DIALOGUE:
		print("[Sistema] Opções de escolha resetadas")

# Função para configurar a colisão do sofá
func setup_couch_collision() -> void:
	# Tenta localizar o nó do quarto que contém o sofá
	var quarto_casa = get_node_or_null("QuartoCasa")
	if not quarto_casa:
		printerr("Nó QuartoCasa não encontrado!")
		return
		
	# Tenta localizar o nó do sofá diretamente
	var sofa = quarto_casa.get_node_or_null("Sofa")
	if not sofa:
		printerr("Nó do sofá não encontrado!")
		return
	
	# Criar corpo de colisão para o sofá
	var static_body = StaticBody2D.new()
	static_body.name = "SofaCollision"
	
	# Criar forma de colisão
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	
	# Definir tamanho da colisão (ajustar conforme necessário)
	shape.size = Vector2(120, 30)
	collision.shape = shape
	
	# Posicionar a colisão relativamente ao sofá
	collision.position = Vector2(0, 10)  # Ajustar posição conforme necessário
	
	# Adicionar colisão ao corpo estático
	static_body.add_child(collision)
	
	# Adicionar o corpo estático ao sofá
	sofa.add_child(static_body)
	
	print("Colisão do sofá configurada com sucesso!")
	
# Função para encontrar um nó pelo nome em toda a árvore
func find_node_by_name(node_name: String) -> Node:
	return find_node_recursive(self, node_name)
	
func find_node_recursive(root: Node, node_name: String) -> Node:
	if root.name == node_name:
		return root
		
	for child in root.get_children():
		var found = find_node_recursive(child, node_name)
		if found:
			return found
			
	return null

# Nota: Esta função foi substituída pelo novo sistema em prologue_doors.gd
# A função setup_door_transition foi removida

# Nota: Sistema antigo de portas foi substituído pelo script prologue_doors.gd
# As funções _on_door_area_entered e _on_door_area_exited foram removidas

# Nota: Estas funções foram substituídas pelo novo sistema de portas interativas
# As funções _show_door_interaction_hint, _hide_door_interaction_hint e _transition_to_next_scene foram removidas

# Função removida: _show_skip_dialogue_option
# O prólogo agora pula automaticamente quando já foi concluído anteriormente
