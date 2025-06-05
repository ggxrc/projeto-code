extends CanvasLayer

@onready var description_label: Label = $BackgroundBoxDescription/DescriptionTextLabel
@onready var background_box: Control = $BackgroundBoxDescription # Referência ao PanelContainer/ColorRect

signal dialogue_line_finished

var _current_tween: Tween = null

# Verifica se o texto está sendo digitado (efeito de typewriter ativo)
func is_typewriting() -> bool:
	return _current_tween != null and _current_tween.is_valid() and _current_tween.is_running()

func _ready() -> void:
	self.visible = false # Começa invisível
	if is_instance_valid(description_label):
		description_label.visible_ratio = 0.0

# Mostra uma descrição.
# speed > 0 para efeito máquina de escrever, speed <= 0 para instantâneo.
func show_description(text_content: String, speed: float = 0.03) -> void:
	if not is_instance_valid(description_label) or not is_instance_valid(background_box):
		printerr("DescriptionBox: Nó Label ou Background não encontrado!")
		return

	# Para qualquer tween anterior
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
		_current_tween = null
	
	description_label.text = text_content
	self.visible = true
	# background_box.visible = true # Já deve estar visível se 'self' está visível

	if speed > 0 and text_content.length() > 0: # Efeito máquina de escrever
		description_label.visible_ratio = 0.0
		_current_tween = create_tween()
		_current_tween.tween_property(description_label, "visible_ratio", 1.0, len(text_content) * speed)
		_current_tween.tween_callback(_on_typewriter_finished)
		_current_tween.play()
	else: # Mostrar instantaneamente
		description_label.visible_ratio = 1.0
		_on_typewriter_finished()

func _on_typewriter_finished() -> void:
	_current_tween = null
	dialogue_line_finished.emit()

func hide_box() -> void:
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
		_current_tween = null
		
	self.visible = false
	if is_instance_valid(description_label):
		description_label.text = ""
		description_label.visible_ratio = 0.0

# Permite pular o efeito de máquina de escrever
func skip_typewriter_effect() -> void:
	if not self.visible: return

	if _current_tween and _current_tween.is_valid() and _current_tween.is_running():
		_current_tween.kill() 
		_current_tween = null
		if is_instance_valid(description_label):
			description_label.visible_ratio = 1.0
		# Se você adicionou o sinal:
		# description_shown_completely.emit()
