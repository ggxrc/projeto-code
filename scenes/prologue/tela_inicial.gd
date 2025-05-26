extends Control

@onready var texto_inicial : Label = $CenterContainer/Texto
@onready var tela_preta : ColorRect = $ColorRect

@onready var control = $Prologue/CanvasLayer/TelaInicial
@onready var canvas = $Prologue/CanvasLayer

var fade_in_time: float = 4 # O texto levará 1.0 segundo para aparecer
# Se quiser que o fundo esmaeça depois, defina a duração aqui também
var fade_out_time: float = 1.5

func _ready() -> void:
	# 1. Configura o texto para começar transparente
	var cor_inicial_texto = texto_inicial.modulate
	cor_inicial_texto.a = 0.0 # 'a' é o canal alfa (transparência). 0.0 = totalmente transparente.
	texto_inicial.modulate = cor_inicial_texto
	change_texto("duvido kkkkkkkkkkk")

func change_texto(texto: String) -> void:
	fade_in_texto()
	await fade_in_texto()
	fade_out_texto()
	await fade_out_texto()
	if texto_inicial.text != texto:
		texto_inicial.text = texto
		change_texto(texto)
	else:
		fade_out_tela()

func fade_in_texto() -> void:
	# 3. Cria um 'Tween' para animar propriedades ao longo do tempo
	var tween_texto = get_tree().create_tween()

	tween_texto.tween_property(texto_inicial, "modulate:a", 1.0, fade_in_time)
	await tween_texto.finished

func fade_out_texto() -> void:
	var tween_texto = get_tree().create_tween()
	tween_texto.tween_property(texto_inicial, "modulate:a", 0.0, fade_out_time)
	await tween_texto.finished

func fade_out_tela() -> void:
	var tween_fundo = get_tree().create_tween()
	tween_fundo.tween_property(tela_preta, "modulate:a", 0.0, fade_out_time)
