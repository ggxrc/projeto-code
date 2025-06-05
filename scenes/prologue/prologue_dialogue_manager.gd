extends Node

# Referências para as cenas de diálogo
@onready var dialogue_box = $DialogueBox
@onready var choice_dialogue_box = $ChoiceDialogueBox
@onready var player_sleeping = $PlayerSleeping

signal dialogue_sequence_completed

enum DialogueState {
	INTRO,
	FIRST_CHOICE,
	SECOND_CHOICE,
	BLUE_PATH,
	YELLOW_PATH,
	CONCLUSION
}

var current_state = DialogueState.INTRO
var current_text_index = 0
var selected_option = -1

# Textos do roteiro
var intro_texts = [
	"Seja bem vindo(a), vejo que você é novo por aqui, você pode achar que o começo é fácil, mas você sabe o que fazer?",
	"*revela-se o quarto do protagonista, dormindo em sua cama*",
	"*ele está dormindo, o que você vai fazer?*"
]

var first_choices = [
	"a) acordar",
	"b) levantar",
	"c) abrir o olho",
	"d) sair da cama"
]

var after_first_choice_texts = {
	0: "ótimo, está indo no caminho certo", # acordar
	1: "vai levantar dormindo?", # levantar
	2: "vai abrir o olho dormindo?", # abrir o olho
	3: "que eu saiba ele não é sonâmbulo" # sair da cama
}

var second_choices = [
	"b) levantar",
	"c) abrir o olho", 
	"d) sair da cama"
]

var after_second_choice_texts = {
	0: "isso mesmo", # levantar
	1: "isso mesmo", # abrir o olho
	2: "vai sair deitado?" # sair da cama
}

var blue_path_texts = [
	"*protagonista cai da cama*",
	"muito bem, você esbagaçou ele no chão, mas, tecnicamente funciona... então, o que vem agora?"
]

var blue_path_choices = [
	"a) levantar",
	"b) abrir o olho"
]

var blue_path_responses = {
	0: "maravilha, você levantou, mas por que até agora você não abriu o olho?", # levantar
	1: "de que adianta abrir o olho se você ainda tá no chão?" # abrir o olho
}

var yellow_path_texts = [
	"agora que você (levantou/abriu o olho), só sobra uma opção",
	"*executa a ação que falta*",
	"*protagonista agora em pé*",
	"maravilha, agora ele acordou e está em pé, mas então... você sabe o que fez?"
]

var conclusion_texts = [
	"O que você acabou de ver foi um algoritmo, um passo a passo lógico para concluir um objetivo.",
	"O objetivo dele era acordar e sair da cama, o que significa que você concluiu seu primeiro algoritmo."
]

func _ready():
	if dialogue_box:
		dialogue_box.dialogue_line_finished.connect(_on_dialogue_line_finished)
	
	if choice_dialogue_box:
		choice_dialogue_box.choice_selected.connect(_on_choice_selected)
		choice_dialogue_box.visible = false
	
	# Iniciar a sequência quando o nó estiver pronto
	call_deferred("start_dialogue_sequence")

func start_dialogue_sequence():
	current_state = DialogueState.INTRO
	current_text_index = 0
	show_intro_text(current_text_index)

func show_intro_text(index: int):
	if index < intro_texts.size():
		dialogue_box.visible = true
		choice_dialogue_box.visible = false
		dialogue_box.show_line(intro_texts[index])
	else:
		show_choice_options(DialogueState.FIRST_CHOICE)

func show_choice_options(state: DialogueState):
	dialogue_box.hide_box()
	choice_dialogue_box.visible = true
	
	match state:
		DialogueState.FIRST_CHOICE:
			choice_dialogue_box.show_choices(first_choices, "O que você vai fazer?")
		DialogueState.SECOND_CHOICE:
			choice_dialogue_box.show_choices(second_choices, "Agora que ele está acordado, o que vem depois?")
		DialogueState.BLUE_PATH:
			choice_dialogue_box.show_choices(blue_path_choices, "O que vem agora?")

func _on_dialogue_line_finished():
	current_text_index += 1
	
	match current_state:
		DialogueState.INTRO:
			if current_text_index < intro_texts.size():
				show_intro_text(current_text_index)
			else:
				current_state = DialogueState.FIRST_CHOICE
				show_choice_options(DialogueState.FIRST_CHOICE)
		
		DialogueState.FIRST_CHOICE, DialogueState.SECOND_CHOICE:
			# Aqui, após mostrar a resposta à escolha do usuário, mostramos a próxima etapa
			if selected_option == 0:  # Caminho correto: acordar
				current_state = DialogueState.SECOND_CHOICE
				show_choice_options(DialogueState.SECOND_CHOICE)
			else:
				# Volta para a primeira escolha com feedback
				show_choice_options(DialogueState.FIRST_CHOICE)
		
		DialogueState.BLUE_PATH:
			if current_text_index < blue_path_texts.size():
				dialogue_box.show_line(blue_path_texts[current_text_index])
			else:
				show_choice_options(DialogueState.BLUE_PATH)
				
		DialogueState.YELLOW_PATH:
			if current_text_index < yellow_path_texts.size():
				dialogue_box.show_line(yellow_path_texts[current_text_index])
			else:
				current_state = DialogueState.CONCLUSION
				current_text_index = 0
				dialogue_box.show_line(conclusion_texts[current_text_index])
				
		DialogueState.CONCLUSION:
			if current_text_index < conclusion_texts.size():
				dialogue_box.show_line(conclusion_texts[current_text_index])
			else:
				dialogue_box.hide_box()
				choice_dialogue_box.hide_box()
				dialogue_sequence_completed.emit()

func _on_choice_selected(choice_index: int):
	selected_option = choice_index
	dialogue_box.visible = true
	choice_dialogue_box.visible = false
	
	match current_state:
		DialogueState.FIRST_CHOICE:
			dialogue_box.show_line(after_first_choice_texts[choice_index])
			# Se escolheu "acordar", avança, caso contrário, volta para mostrar opções
			if choice_index == 0:  # "a) acordar" - Caminho correto
				current_text_index = 0
				current_state = DialogueState.SECOND_CHOICE
			else:
				current_text_index = -1  # Para que _on_dialogue_line_finished incremente para 0
			
		DialogueState.SECOND_CHOICE:
			dialogue_box.show_line(after_second_choice_texts[choice_index])
			
			if choice_index == 2:  # 'd) sair da cama' - Opção AZUL
				current_state = DialogueState.BLUE_PATH
				current_text_index = -1  # Para que _on_dialogue_line_finished incremente para 0
			else:  # Outras opções - Caminho AMARELO
				current_state = DialogueState.YELLOW_PATH
				current_text_index = -1  # Para que _on_dialogue_line_finished incremente para 0
				
		DialogueState.BLUE_PATH:
			dialogue_box.show_line(blue_path_responses[choice_index])
			# Após resposta do caminho azul, vamos direto para conclusão
			current_state = DialogueState.CONCLUSION
			current_text_index = -1  # Para que _on_dialogue_line_finished incremente para 0
