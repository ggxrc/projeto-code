extends CanvasLayer

@onready var text_label: Label = $BackgroundBox/TextLabel
@onready var choices_container: VBoxContainer = $BackgroundBox/ChoicesContainer
@onready var background_box: Control = $BackgroundBox

signal dialogue_line_finished
signal choice_selected(choice_index: int)

var _current_tween: Tween = null
var choice_buttons: Array[Button] = []

func _ready() -> void:
	self.visible = false
	if is_instance_valid(text_label):
		text_label.visible_ratio = 0.0
	if is_instance_valid(choices_container):
		choices_container.visible = false
		
func show_line(text_content: String, speed: float = 0.03) -> void:
	if not is_instance_valid(text_label) or not is_instance_valid(background_box):
		printerr("DialogueBox: Nó TextLabel ou BackgroundBox não encontrado!")
		return
		
	# Esconde as opções de escolha quando mostramos novo texto
	if is_instance_valid(choices_container):
		choices_container.visible = false

	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
		_current_tween = null
	
	text_label.text = text_content
	self.visible = true

	if speed > 0 and text_content.length() > 0:
		text_label.visible_ratio = 0.0
		_current_tween = create_tween()
		_current_tween.tween_property(text_label, "visible_ratio", 1.0, len(text_content) * speed)
		_current_tween.tween_callback(_on_typewriter_finished)
		_current_tween.play()
	else:
		text_label.visible_ratio = 1.0
		_on_typewriter_finished()

func _on_typewriter_finished() -> void:
	_current_tween = null
	dialogue_line_finished.emit()

func hide_box() -> void:
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
		_current_tween = null
		
	self.visible = false
	if is_instance_valid(text_label):
		text_label.text = ""
		text_label.visible_ratio = 0.0
		
	if is_instance_valid(choices_container):
		choices_container.visible = false
		# Limpar as escolhas anteriores
		for button in choice_buttons:
			button.queue_free()
		choice_buttons.clear()

func advance_or_skip_typewriter() -> void:
	if not is_instance_valid(text_label):
		return
		
	if _current_tween and _current_tween.is_valid():
		# Se o texto ainda está digitando, complete-o imediatamente
		_current_tween.kill()
		_current_tween = null
		text_label.visible_ratio = 1.0
		dialogue_line_finished.emit()

# Mostra opções de escolha para o jogador
func show_choices(choices: Array, title: String = "") -> void:
	if not is_instance_valid(choices_container):
		printerr("ChoiceDialogueBox: Container de escolhas não encontrado!")
		return
	
	# Definir o título/pergunta
	if is_instance_valid(text_label):
		text_label.text = title
		text_label.visible_ratio = 1.0
		
	# Limpar escolhas anteriores
	for button in choice_buttons:
		button.queue_free()
	choice_buttons.clear()
	
	# Criar novos botões para cada escolha
	for i in range(choices.size()):
		var choice = choices[i]
		var button = Button.new()
		button.text = choice
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_choice_button_pressed.bind(i))
		
		choices_container.add_child(button)
		choice_buttons.append(button)
	
	self.visible = true
	choices_container.visible = true

func _on_choice_button_pressed(choice_index: int) -> void:
	choice_selected.emit(choice_index)

# Função para obter o texto de uma opção pelo seu índice
func get_option_text(choice_index: int) -> String:
	if choice_index >= 0 and choice_index < choice_buttons.size():
		return choice_buttons[choice_index].text
	return ""
