extends CanvasLayer

@onready var text_label: Label = $BackgroundBox/TextLabel
@onready var background_box: Control = $BackgroundBox

signal dialogue_line_finished

# Referência ao AudioManager
var audio_manager: Node

var _current_tween: Tween = null

func _ready() -> void:
	self.visible = false
	if is_instance_valid(text_label):
		text_label.visible_ratio = 0.0
	
	# Verificar se o AudioManager está disponível como singleton
	if Engine.has_singleton("AudioManager"):
		audio_manager = Engine.get_singleton("AudioManager")
		
# Verifica se o texto está sendo digitado (efeito de typewriter ativo)
func is_typewriting() -> bool:
	return _current_tween != null and _current_tween.is_valid() and _current_tween.is_running()

func show_line(text_content: String, speed: float = 0.05) -> void:
	if not is_instance_valid(text_label) or not is_instance_valid(background_box):
		printerr("DialogueBox: Nó TextLabel ou BackgroundBox não encontrado!")
		return

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
		
		# Conectar o sinal para tocar som a cada caractere revelado
		if not _current_tween.step_finished.is_connected(_on_character_revealed):
			_current_tween.step_finished.connect(_on_character_revealed)
			
		_current_tween.play()
	else:
		text_label.visible_ratio = 1.0
		_on_typewriter_finished()

func _on_character_revealed(_value: float, _object: Object) -> void:
	# Tocar som de digitação com variações de pitch para não ficar monótono
	if audio_manager:
		var random_pitch = randf_range(0.95, 1.05)
		audio_manager.play_sfx("dialogue_typing", 0.2, random_pitch)

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

func advance_or_skip_typewriter() -> void:
	if not self.visible: return

	if _current_tween and _current_tween.is_valid() and _current_tween.is_running():
		# Tocar som de "avançar rápido"
		if audio_manager:
			audio_manager.play_sfx("button_click", 0.3)
			
		_current_tween.kill() 
		if is_instance_valid(text_label):
			text_label.visible_ratio = 1.0
		_on_typewriter_finished() 
	else:
		if is_instance_valid(text_label) and text_label.visible_ratio >= 1.0:
			dialogue_line_finished.emit()
		pass
