extends Control

# LoadingScreen.gd - Gerencia a tela de carregamento

@onready var animated_sprite = $Control/AnimatedSprite2D
@onready var text_label = $Control/Texto
@onready var animation_player = $AnimationPlayer

signal loading_finished

# Tempo mínimo e máximo da tela de loading (em segundos)
const MIN_LOADING_TIME: float = 0.5
const MAX_LOADING_TIME: float = 3.0

# Variável para guardar o timer
var loading_timer: SceneTreeTimer = null
var is_loading: bool = false

func _ready() -> void:
	# Garante que a tela comece invisível
	visible = false
	
	# Verifica se os nodes necessários estão presentes
	if not animated_sprite:
		push_warning("LoadingScreen: AnimatedSprite2D não encontrado")
	
	if not animation_player:
		push_warning("LoadingScreen: AnimationPlayer não encontrado")
	else:
		# Garante que a animação está configurada para começar automaticamente
		animation_player.autoplay = "loading_rotation"

# Mostra a tela de carregamento
func show_screen():
	print("LoadingScreen: Exibindo tela de carregamento")
	visible = true
	
	# Ativa a animação do sprite
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("default"):
		animated_sprite.play("default")
	
	# Inicia a animação de rotação
	if animation_player and animation_player.has_animation("loading_rotation"):
		animation_player.play("loading_rotation")

# Esconde a tela de carregamento
func hide_screen():
	print("LoadingScreen: Escondendo tela de carregamento")
	visible = false
	
	# Para a animação
	if animated_sprite:
		animated_sprite.stop()
	
	# Emite o sinal que o carregamento acabou
	emit_signal("loading_finished")

# Atualiza o progresso de carregamento
func update_progress(value: float):
	# Atualizar texto se necessário
	if text_label:
		var percentage = int(value * 100)
		text_label.text = "Carregando... %d%%" % percentage
