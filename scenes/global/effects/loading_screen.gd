extends CanvasLayer

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
	
	# Garante que está na camada correta para ficar acima de outros elementos
	layer = 101  # Superior ao TransitionScreen (layer 100)
	
	# Verifica se os nodes necessários estão presentes
	if not animated_sprite:
		push_warning("LoadingScreen: AnimatedSprite2D não encontrado")
	
	if not animation_player:
		push_warning("LoadingScreen: AnimationPlayer não encontrado")
	else:
		# Garante que a animação está configurada para começar automaticamente
		animation_player.autoplay = "loading_rotation"

# Inicia o processo de loading com integração ao TransitionScreen
# transitions: true para usar fade in/out, false para aparecer/desaparecer diretamente
func start_loading(transitions: bool = true) -> void:
	print("### MÉTODO START_LOADING CHAMADO ###")
	
	if is_loading:
		print("Já está em loading, ignorando.")
		return
		
	is_loading = true
	print("LoadingScreen: Iniciando carregamento...")
	debug_status()
	
	# Ativa a animação do sprite
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("default"):
		animated_sprite.play("default")
	
	# Inicia a animação de rotação
	if animation_player and animation_player.has_animation("loading_rotation"):
		animation_player.play("loading_rotation")
	
	if transitions and TransitionScreen and TransitionScreen.has_method("fade_out"):
		# Primeiro usa o TransitionScreen para fade out
		visible = true
		TransitionScreen.fade_out()
		await TransitionScreen.fade_out_finished
	else:
		# Sem transição, apenas mostra
		visible = true
	
	# Gera um tempo aleatório entre os limites definidos
	var loading_time = randf_range(MIN_LOADING_TIME, MAX_LOADING_TIME)
	
	# Cria o timer para simular o tempo de carregamento
	loading_timer = get_tree().create_timer(loading_time)
	await loading_timer.timeout
	
	# Processo de loading terminado
	finish_loading(transitions)

# Finaliza o processo de loading
func finish_loading(with_transition: bool = true) -> void:
	if not is_loading:
		return
	
	if with_transition and TransitionScreen and TransitionScreen.has_method("fade_in"):
		# Usa o TransitionScreen para fade in
		TransitionScreen.fade_in()
		await TransitionScreen.fade_in_finished
		visible = false
	else:
		# Sem transição, apenas esconde
		visible = false
	
	# Para as animações
	if animated_sprite:
		animated_sprite.stop()
	
	if animation_player:
		animation_player.stop()
		is_loading = false
	print("LoadingScreen: Carregamento concluído!")
	debug_status()
	loading_finished.emit()

# Versão conveniente que permite definir um valor fixo para o tempo de loading
func start_loading_with_fixed_time(time: float, transitions: bool = true) -> void:
	if is_loading:
		return
	
	is_loading = true
	
	print("LoadingScreen: Iniciando carregamento com tempo fixo: ", time)
	
	# Ativa a animação do sprite
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("default"):
		animated_sprite.play("default")
	
	# Inicia a animação de rotação
	if animation_player and animation_player.has_animation("loading_rotation"):
		animation_player.play("loading_rotation")
	
	if transitions and TransitionScreen and TransitionScreen.has_method("fade_out"):
		# Primeiro usa o TransitionScreen para fade out
		visible = true
		TransitionScreen.fade_out()
		await TransitionScreen.fade_out_finished
	else:
		# Sem transição, apenas mostra
		visible = true
	
	# Usa o tempo fixo passado como parâmetro
	loading_timer = get_tree().create_timer(time)
	await loading_timer.timeout
	
	# Processo de loading terminado
	finish_loading(transitions)

# Método de depuração que imprime o estado atual da tela de loading
func debug_status() -> void:
	print("======= LOADING SCREEN STATUS =======")
	print("Visibilidade: ", visible)
	print("Is Loading: ", is_loading)
	print("Timer Ativo: ", loading_timer != null and loading_timer.time_left > 0 if loading_timer else false)
	print("AnimatedSprite: ", animated_sprite != null)
	if animated_sprite:
		print("  - Has SpriteFrames: ", animated_sprite.sprite_frames != null)
		if animated_sprite.sprite_frames:
			print("  - Current Animation: ", animated_sprite.animation)
			print("  - Frame: ", animated_sprite.frame)
	print("AnimationPlayer: ", animation_player != null)
	if animation_player:
		print("  - Current Animation: ", animation_player.current_animation)
		print("  - Playing: ", animation_player.is_playing())
	print("=====================================")
