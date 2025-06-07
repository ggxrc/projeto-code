extends Control

@onready var texto_label: Label = $CenterContainer/Texto
@onready var fundo_preto: ColorRect = $ColorRect

signal linha_exibida_completamente

var _tween_ativo: Tween = null
var _esta_exibindo: bool = false

func _ready() -> void:
	if texto_label:
		texto_label.modulate.a = 0.0
	if fundo_preto:
		fundo_preto.modulate.a = 0.0
		fundo_preto.visible = false

func mostrar_fundo(fade_duracao: float = 0.5) -> void:
	if not is_instance_valid(fundo_preto): return
	
	if _tween_ativo and _tween_ativo.is_valid():
		_tween_ativo.kill()

	fundo_preto.modulate.a = 0.0
	fundo_preto.visible = true
	
	_tween_ativo = create_tween()
	_tween_ativo.tween_property(fundo_preto, "modulate:a", 1.0, fade_duracao)
	await _tween_ativo.finished

func exibir_linha_dialogo(texto: String, tempo_fade: float = 0.75, tempo_leitura: float = 2.0) -> void:
	if not is_instance_valid(texto_label):
		printerr("Nó 'texto_label' não encontrado em TelaInicial!")
		return
	if _esta_exibindo:
		parar_e_limpar_linha_atual()

	_esta_exibindo = true
	texto_label.text = texto
	texto_label.modulate.a = 0.0

	_tween_ativo = create_tween()
	_tween_ativo.set_parallel(false)
	_tween_ativo.set_trans(Tween.TRANS_SINE)
	_tween_ativo.set_ease(Tween.EASE_IN_OUT)

	_tween_ativo.tween_property(texto_label, "modulate:a", 1.0, tempo_fade)
	_tween_ativo.tween_interval(tempo_leitura)
	_tween_ativo.tween_property(texto_label, "modulate:a", 0.0, tempo_fade)
	_tween_ativo.tween_callback(_on_sequencia_linha_finalizada)
	
	_tween_ativo.play()

func _on_sequencia_linha_finalizada() -> void:
	_esta_exibindo = false
	_tween_ativo = null
	linha_exibida_completamente.emit()

func esconder_fundo(fade_duracao: float = 1.0) -> void:
	if not is_instance_valid(fundo_preto): return

	if _tween_ativo and _tween_ativo.is_valid():
		_tween_ativo.kill()
		
	if is_instance_valid(texto_label) and texto_label.modulate.a > 0.0:
		var texto_fade_tween = create_tween()
		texto_fade_tween.tween_property(texto_label, "modulate:a", 0.0, fade_duracao * 0.5)

	_tween_ativo = create_tween()
	_tween_ativo.tween_property(fundo_preto, "modulate:a", 0.0, fade_duracao)
	await _tween_ativo.finished
	if is_instance_valid(fundo_preto):
		fundo_preto.visible = false

func parar_e_limpar_linha_atual() -> void:
	_esta_exibindo = false
	if _tween_ativo and _tween_ativo.is_valid():
		_tween_ativo.kill()
	_tween_ativo = null
	if is_instance_valid(texto_label):
		texto_label.text = ""
		texto_label.modulate.a = 0.0
